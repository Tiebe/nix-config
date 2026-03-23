{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.thunderbird;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = if evictCfg.enable then [
      "L+ ${evictCfg.configDir}/.thunderbird - - - - /persist${evictCfg.configDir}/.thunderbird"
    ] else [
      "L+ /home/tiebe/.thunderbird - - - - /persist/home/tiebe/.thunderbird"
    ];
  };
}
