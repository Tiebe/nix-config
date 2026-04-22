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
in {
  config = mkIf (darlings.enable && cfg.enable) {
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: {
      home.file = mkIf (!evictCfg.enable) {
        "/home/tiebe/.forge".source = config.lib.file.mkOutOfStoreSymlink
          "/persist/home/tiebe/.forge";
      };

      home.activation.createForgecodePersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          ${
          if evictCfg.enable
          then ''
            "/persist${config.users.users.tiebe.home}/.forge"
          ''
          else ''
            "/persist/home/tiebe/.forge"
          ''
        }
      '';
    };
  };
}
