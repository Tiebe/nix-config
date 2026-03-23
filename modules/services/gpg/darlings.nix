{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.gpg;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = if evictCfg.enable then [
      "L ${evictCfg.configDir}/gnupg - - - - /persist${evictCfg.configDir}/gnupg"
    ] else [
      "L /home/tiebe/.gnupg - - - - /persist/home/tiebe/.gnupg"
    ];
  };
}
