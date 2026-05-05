{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.tiebe.system.boot.darlings;
  fs-diff = pkgs.writeShellScriptBin "fs-diff" ''
    set -euo pipefail

    OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/root-blank 9999999)
    OLD_TRANSID=''${OLD_TRANSID#transid marker was }

    sudo btrfs subvolume find-new "/mnt/root" "$OLD_TRANSID" |
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
in
{
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
    boot.initrd.systemd.enable = false;
    boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
      mkdir -p /mnt

      # We first mount the btrfs root to /mnt
      # so we can manipulate btrfs subvolumes.
      mount -o subvol=/ ${config.fileSystems."/".device} /mnt

      # While we're tempted to just delete /root and create
      # a new snapshot from /root-blank, /root is already
      # populated at this point with a number of subvolumes,
      # which makes `btrfs subvolume delete` fail.
      # So, we remove them first.
      #
      # /root contains subvolumes:
      # - /root/var/lib/portables
      # - /root/var/lib/machines
      #
      # I suspect these are related to systemd-nspawn, but
      # since I don't use it I'm not 100% sure.
      # Anyhow, deleting these subvolumes hasn't resulted
      # in any issues so far, except for fairly
      # benign-looking errors from systemd-tmpfiles.
      btrfs subvolume list -o /mnt/root |
      cut -f9 -d' ' |
      while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "deleting /root subvolume..." &&
      btrfs subvolume delete /mnt/root

      echo "restoring blank /root subvolume..."
      btrfs subvolume snapshot /mnt/root-blank /mnt/root

      # Once we're done rolling back to a blank snapshot,
      # we can unmount /mnt and continue on the boot process.
      umount /mnt
    '';
  };
}
