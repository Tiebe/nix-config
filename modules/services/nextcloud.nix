{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.nextcloud;
in {
  options = {
    tiebe.services.nextcloud = {
      enable = mkEnableOption "the Nextcloud client";
    };
  };

  config = mkIf cfg.enable {
      services.davfs2.enable = true;

      systemd.mounts = [
        {
          description = "NextCloud Mount";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          what = "https://cloud.tiebe.me/remote.php/dav/files/tiebe";
          where = "/mnt/nextcloud";
          options = "x-systemd.automount,uid=1000,gid=100";
          type = "davfs";
        }
      ];

      systemd.automounts = [
        {
          description = "NextCloud Automount";
          where = "/mnt/nextcloud";
          wantedBy = [ "multi-user.target" ];
          automountConfig = {
            TimeoutIdleSec = "2m";
          };
        }
      ];

      age.secrets.davfs = {
        file = ../../secrets/davfs.age;
        mode = "600";
        path = "/etc/davfs2/secrets";
      };
  };
}
