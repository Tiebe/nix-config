{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.steam;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Steam library and config persistence
    home-manager.users.tiebe = { config, ... }: {
      xdg.dataFile."Steam".source = if evictCfg.enable then
        config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/local/share/Steam"
      else
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.local/share/Steam";
      xdg.configFile."steam".source = if evictCfg.enable then
        config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/steam"
      else
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/steam";
    };
  };
}
