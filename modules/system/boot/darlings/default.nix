{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  utils,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.tiebe.system.boot.darlings;
  fs-diff = pkgs.writeShellScriptBin "fs-diff" ''
    set -euo pipefail

    ROOT_SOURCE=$(findmnt -no SOURCE /)
    ROOT_FSTYPE=$(findmnt -no FSTYPE /)
    ROOT_SOURCE="''${ROOT_SOURCE%%[[]*}"

    if [ "$ROOT_FSTYPE" != "btrfs" ]; then
      echo "fs-diff: / is not mounted on btrfs" >&2
      exit 1
    fi

    cleanup_mounts=()

    cleanup() {
      for mountpoint in "''${cleanup_mounts[@]}"; do
        sudo umount "$mountpoint"
        rmdir "$mountpoint"
      done
    }

    trap cleanup EXIT

    resolve_mount() {
      subvol="$1"
      candidate="$2"

      if [ -d "$candidate" ] && [ "$(findmnt -rn -T "$candidate" -o TARGET -n 2>/dev/null || true)" = "$candidate" ]; then
        printf '%s\n' "$candidate"
        return 0
      fi

      mountpoint=$(mktemp -d /tmp/fs-diff.XXXXXX)
      cleanup_mounts+=("$mountpoint")
      sudo mount -o "subvol=$subvol,ro" "$ROOT_SOURCE" "$mountpoint"
      printf '%s\n' "$mountpoint"
    }

    ROOT_MOUNT=$(resolve_mount root /mnt/root)
    ROOT_BLANK_MOUNT=$(resolve_mount root-blank /mnt/root-blank)

    OLD_TRANSID=$(sudo btrfs subvolume find-new "$ROOT_BLANK_MOUNT" 9999999)
    OLD_TRANSID=''${OLD_TRANSID#transid marker was }

    sudo btrfs subvolume find-new "$ROOT_MOUNT" "$OLD_TRANSID" |
      sed '$d' |
      cut -f17- -d' ' |
      sort |
      uniq |
      while read path; do
        path="/$path"
        if [ -L "$path" ]; then
          : # The path is a symbolic link, so is probably handled by NixOS already
        elif [ -d "$path" ]; then
          : # The path is a directory, ignore
        else
          echo "$path"
        fi
      done
  '';
in {
  options = {
    tiebe.system.boot.darlings = {
      enable = mkEnableOption "Erase your darlings";
    };
  };

  config = mkIf cfg.enable {
    # Core boot persistence - system-wide settings
    environment.etc = {
      nixos.source = "/persist/etc/nixos";
      machine-id.source = "/persist/etc/machine-id";
    };

    security.sudo.extraConfig = "Defaults lecture=\"never\"";

    environment.systemPackages = [fs-diff];

    users.mutableUsers = false;
    boot.initrd.systemd.services.darlings-rollback = {
      description = "Restore the blank Btrfs root subvolume";
      requiredBy = ["sysroot.mount"];
      before = ["sysroot.mount"];
      after = ["${utils.escapeSystemdPath config.fileSystems."/".device}.device"];
      requires = ["${utils.escapeSystemdPath config.fileSystems."/".device}.device"];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [
        pkgs.btrfs-progs
        pkgs.coreutils
        pkgs.util-linux
      ];
      script = ''
        set -euo pipefail
        mkdir -p /mnt

        # Mount the top-level subvolume before systemd mounts /sysroot.
        mount -t btrfs -o subvol=/ ${lib.escapeShellArg config.fileSystems."/".device} /mnt
        trap 'umount /mnt' EXIT

        # Remove nested subvolumes (such as var/lib/portables and machines)
        # before replacing the root subvolume with the blank snapshot.
        btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read -r subvolume; do
          echo "deleting /$subvolume subvolume..."
          btrfs subvolume delete "/mnt/$subvolume"
        done
        echo "deleting /root subvolume..."
        btrfs subvolume delete /mnt/root

        echo "restoring blank /root subvolume..."
        btrfs subvolume snapshot /mnt/root-blank /mnt/root
      '';
    };
  };
}
