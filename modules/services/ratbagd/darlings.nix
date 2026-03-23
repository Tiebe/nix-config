{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.ratbagd;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "L /var/lib/ratbagd - - - - /persist/var/lib/ratbagd"
    ];
  };
}
