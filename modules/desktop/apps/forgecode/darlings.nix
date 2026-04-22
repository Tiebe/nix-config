{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.forgecode;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;

  forgeDir =
    if evictCfg.enable
    then "${evictCfg.baseDir}/.forge"
    else "/home/tiebe/.forge";

  persistForgeDir =
    if evictCfg.enable
    then "/persist${evictCfg.baseDir}/.forge"
    else "/persist/home/tiebe/.forge";
in {
  config = mkIf (darlings.enable && cfg.enable) {
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: {
      home.file."${forgeDir}".source =
        config.lib.file.mkOutOfStoreSymlink persistForgeDir;

      home.activation.createForgecodePersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG "${persistForgeDir}"
      '';
    };
  };
}

