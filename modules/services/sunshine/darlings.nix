{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.sunshine;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Sunshine credentials, pairing state, and certificates
    systemd.tmpfiles.rules = if evictCfg.enable then [
      "L ${evictCfg.configDir}/sunshine - - - - /persist${evictCfg.configDir}/sunshine"
    ] else [
      "L /home/tiebe/.config/sunshine - - - - /persist/home/tiebe/.config/sunshine"
    ];
  };
}
