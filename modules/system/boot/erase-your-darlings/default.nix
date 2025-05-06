{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.boot.erase-your-darlings;
in {
  options = {
    tiebe.system.boot.erase-your-darlings = {
      enable = mkEnableOption "Erase your darlings";
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.postResumeCommands = lib.mkAfter ''
      echo "Rolling back root partition..."
      zfs rollback -r rpool/local/root@blank
      echo ">> ROLLBACK COMPLETE <<"
    '';

    services.udev.extraRules = ''
      KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '';

    nix.nixPath = ["nix-config=/persist/etc/nixos"];

    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
      # TODO: autoReplication
    };

    services.openssh = {
      hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };

    users.mutableUsers = false;
  };
}
