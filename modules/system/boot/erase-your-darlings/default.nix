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

    environment.etc = {
      nixos.source = "/persist/etc/nixos";
      machine-id.source = "/persist/etc/machine-id";
    };

    security.sudo.extraConfig = "Defaults lecture=\"never\"";

    systemd.tmpfiles.rules = [
      "L /var/lib/docker - - - - /persist/var/lib/docker"
      "L /var/lib/fprint - - - - /persist/var/lib/fprint"
      "L+ /var/lib/systemd/backlight - - - - /persist/var/lib/systemd/backlight"
    ];

    systemd.services.fprintd.serviceConfig.StateDirectory = "";
    systemd.services."systemd-backlight@" = { 
      environment = {
        "SYSTEMD_LOG_LEVEL" = "debug";
        "SYSTEMD_LOG_TARGET" = "journal";
      };
      requires = [ "persist.mount" ];
      after = [ "persist.mount" ];
      serviceConfig.StateDirectory = "";
    };

    users.mutableUsers = false;
  };
}
