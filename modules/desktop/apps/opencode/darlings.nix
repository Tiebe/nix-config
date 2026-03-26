{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.opencode;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    home-manager.users.tiebe = { config, ... }: {
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
    };
  };
}
