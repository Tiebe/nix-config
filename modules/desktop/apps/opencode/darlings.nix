{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.opencode;
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
          # Persist opencode state directories in evict-darlings structure
          "${evictCfg.configDir}/local/share/opencode".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist${evictCfg.configDir}/local/share/opencode";
          "${evictCfg.configDir}/local/share/ai.opencode.desktop".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist${evictCfg.configDir}/local/share/ai.opencode.desktop";
          "${evictCfg.configDir}/local/state/opencode".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist${evictCfg.configDir}/local/state/opencode";
        }
        else {
          # Standard home directory structure
          "/home/tiebe/.local/share/opencode".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist/home/tiebe/.local/share/opencode";
          "/home/tiebe/.local/share/ai.opencode.desktop".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist/home/tiebe/.local/share/ai.opencode.desktop";
          "/home/tiebe/.local/state/opencode".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist/home/tiebe/.local/state/opencode";
        };

      # Create the target directories in /persist before symlinks are set up
      home.activation.createOpencodePersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          ${
          if evictCfg.enable
          then ''
            "/persist${evictCfg.configDir}/local/share/opencode" \
            "/persist${evictCfg.configDir}/local/share/ai.opencode.desktop" \
            "/persist${evictCfg.configDir}/local/state/opencode"
          ''
          else ''
            "/persist/home/tiebe/.local/share/opencode" \
            "/persist/home/tiebe/.local/share/ai.opencode.desktop" \
            "/persist/home/tiebe/.local/state/opencode"
          ''
        }
      '';
    };
  };
}
