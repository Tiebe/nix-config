{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.printing;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # CUPS printing system state persistence
    systemd.tmpfiles.rules = [
      "L /var/lib/cups - - - - /persist/var/lib/cups"
      "L /var/spool/cups - - - - /persist/var/spool/cups"
    ];
  };
}
