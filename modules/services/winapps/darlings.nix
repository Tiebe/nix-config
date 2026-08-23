{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.winapps;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d /persist/var/lib/winapps 0700 root root -"
    ];

    systemd.services."docker-WinApps" = {
      after = ["persist.mount"];
      requires = ["persist.mount"];
    };
  };
}
