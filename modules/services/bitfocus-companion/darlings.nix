{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.bitfocus-companion;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules =
      if evictCfg.enable
      then [
        "L ${evictCfg.configDir}/Companion - - - - /persist${evictCfg.configDir}/Companion"
      ]
      else [
        "L /home/tiebe/.config/Companion - - - - /persist/home/tiebe/.config/Companion"
      ];
  };
}
