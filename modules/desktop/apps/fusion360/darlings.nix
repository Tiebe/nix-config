{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.fusion360;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
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

      fusionDir = "${homeRoot}/.autodesk_fusion";
      fusionPersistDir = "${persistRoot}/.autodesk_fusion";
    in {
      home.activation.createFusion360PersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          "${fusionPersistDir}/wineprefixes" \
          "${fusionPersistDir}/logs" \
          "${fusionPersistDir}/downloads"
      '';

      home.activation.createFusion360Symlinks = lib.hm.dag.entryAfter ["createFusion360PersistDirs" "writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -rf $VERBOSE_ARG "${fusionDir}"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfn "${fusionPersistDir}" "${fusionDir}"
      '';
    };
  };
}
