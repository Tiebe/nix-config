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
      homeRoot =
        if evictCfg.enable
        then evictCfg.configDir
        else "/home/tiebe";

      persistRoot =
        if evictCfg.enable
        then "/persist${evictCfg.configDir}"
        else "/persist/home/tiebe";

      steamStateRoot = "${homeRoot}/.steam";
      steamDataRoot = "${homeRoot}/.local/share/Steam";
      steamConfigRoot = "${homeRoot}/.config/steam";
      daedalicRoot = "${homeRoot}/.local/share/Daedalic Entertainment GmbH";

      steamStatePersistRoot = "${persistRoot}/.steam";
      steamDataPersistRoot = "${persistRoot}/.local/share/Steam";
      steamConfigPersistRoot = "${persistRoot}/.config/steam";
      daedalicPersistRoot = "${persistRoot}/.local/share/Daedalic Entertainment GmbH";
    in {
      # Create the target directories in /persist and the live symlink parents
      home.activation.createSteamPersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          "${steamStatePersistRoot}" \
          "${steamDataPersistRoot}" \
          "${steamConfigPersistRoot}" \
          "${daedalicPersistRoot}" \
          "${steamStateRoot}" \
          "${homeRoot}/.local/share" \
          "${homeRoot}/.config"
      '';

      home.activation.createSteamSymlinks = lib.hm.dag.entryAfter ["createSteamPersistDirs" "writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${steamStateRoot}/exportedsettings.json"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${steamStateRoot}/registry.vdf"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${steamStateRoot}/steam.pid"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${steamStateRoot}/steam.token"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${steamDataRoot}"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${steamConfigRoot}"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${daedalicRoot}"

        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${steamStatePersistRoot}/exportedsettings.json" "${steamStateRoot}/exportedsettings.json"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${steamStatePersistRoot}/registry.vdf" "${steamStateRoot}/registry.vdf"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${steamStatePersistRoot}/steam.pid" "${steamStateRoot}/steam.pid"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${steamStatePersistRoot}/steam.token" "${steamStateRoot}/steam.token"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${steamDataPersistRoot}" "${steamDataRoot}"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${steamConfigPersistRoot}" "${steamConfigRoot}"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${daedalicPersistRoot}" "${daedalicRoot}"
      '';
    };
  };
}
