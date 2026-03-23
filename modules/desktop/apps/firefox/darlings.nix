{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.firefox;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Firefox profile persistence
    systemd.tmpfiles.rules = if evictCfg.enable then [
      "L+ ${evictCfg.configDir}/.mozilla - - - - /persist${evictCfg.configDir}/.mozilla"
    ] else [
      "L+ /home/tiebe/.mozilla - - - - /persist/home/tiebe/.mozilla"
    ];
  };
}
