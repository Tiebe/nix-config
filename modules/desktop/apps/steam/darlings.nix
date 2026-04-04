{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.steam;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Steam library and config persistence
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: {
      xdg.dataFile."Steam".source =
        if evictCfg.enable
        then config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/local/share/Steam"
        else config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.local/share/Steam";
      xdg.configFile."steam".source =
        if evictCfg.enable
        then config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/steam"
        else config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/steam";

      # Create the target directories in /persist before symlinks are set up
      home.activation.createSteamPersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          ${
          if evictCfg.enable
          then ''
            "/persist${evictCfg.configDir}/local/share/Steam" \
            "/persist${evictCfg.configDir}/steam"
          ''
          else ''
            "/persist/home/tiebe/.local/share/Steam" \
            "/persist/home/tiebe/.config/steam"
          ''
        }
      '';
    };
  };
}
