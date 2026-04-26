{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.waydroid;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "d /persist/var/lib/waydroid 0755 root root -"
      "L+ /var/lib/waydroid - - - - /persist/var/lib/waydroid"
    ];

    systemd.services.waydroid-container = {
      requires = ["persist.mount"];
      after = ["persist.mount"];
    };
  };
}
