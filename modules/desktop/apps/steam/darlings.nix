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
    }: let
      homePrefix =
        if evictCfg.enable
        then "${evictCfg.configDir}/"
        else "";

      persistRoot = "/persist/home/tiebe";

      steamPath = path: "${homePrefix}${path}";
      persistPath = path: "${persistRoot}${path}";
    in {
      home.file."${steamPath ".steam/exportedsettings.json"}".source =
        config.lib.file.mkOutOfStoreSymlink "${persistPath "/.steam/exportedsettings.json"}";

      home.file."${steamPath ".steam/registry.vdf"}".source =
        config.lib.file.mkOutOfStoreSymlink "${persistPath "/.steam/registry.vdf"}";

      home.file."${steamPath ".steam/steam.pid"}".source =
        config.lib.file.mkOutOfStoreSymlink "${persistPath "/.steam/steam.pid"}";

      home.file."${steamPath ".steam/steam.token"}".source =
        config.lib.file.mkOutOfStoreSymlink "${persistPath "/.steam/steam.token"}";

      home.file."${steamPath ".local/share/Daedalic Entertainment GmbH"}".source =
        config.lib.file.mkOutOfStoreSymlink "${persistPath "/.local/share/Daedalic Entertainment GmbH"}";

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
            "/persist${evictCfg.configDir}/.steam" \
            "/persist${evictCfg.configDir}/.local/share/Daedalic Entertainment GmbH" \
            "/persist${evictCfg.configDir}/local/share/Steam" \
            "/persist${evictCfg.configDir}/steam"
          ''
          else ''
            "/persist/home/tiebe/.steam" \
            "/persist/home/tiebe/.local/share/Daedalic Entertainment GmbH" \
            "/persist/home/tiebe/.local/share/Steam" \
            "/persist/home/tiebe/.config/steam"
          ''
        }
      '';
    };
  };
}
