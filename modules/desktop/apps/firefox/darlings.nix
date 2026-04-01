{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.firefox;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: {
      home.file =
        if evictCfg.enable
        then {
          # Firefox runs with HOME=configDir, so it looks at configDir/.mozilla/firefox
          "${evictCfg.configDir}/.mozilla/firefox".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist${evictCfg.configDir}/.mozilla/firefox";
        }
        else {
          # Standard home directory structure
          ".mozilla/firefox".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist/home/tiebe/.mozilla/firefox";
        };

      # CRITICAL: Create /persist directories BEFORE symlinks are created
      home.activation.createFirefoxPersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          ${
          if evictCfg.enable
          then ''
            "/persist${evictCfg.configDir}/.mozilla/firefox"
          ''
          else ''
            "/persist/home/tiebe/.mozilla/firefox"
          ''
        }
      '';
    };
  };
}
