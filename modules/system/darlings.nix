{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf darlings.enable {
    systemd.tmpfiles.rules = [
      "L+ /var/lib/systemd/backlight - - - - /persist/var/lib/systemd/backlight"
    ];

    systemd.services."systemd-backlight@" = {
      environment = {
        "SYSTEMD_LOG_LEVEL" = "debug";
        "SYSTEMD_LOG_TARGET" = "journal";
      };
      requires = ["persist.mount"];
      after = ["persist.mount"];
      serviceConfig.StateDirectory = "";
    };
  };
}
