{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.plasma;
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
          # Persist KDE Wallet data in evict-darlings structure
          "${evictCfg.configDir}/local/share/kwalletd".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist${evictCfg.configDir}/local/share/kwalletd";
          # Persist monitor/display layout configuration
          "${evictCfg.configDir}/local/share/kscreen".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist${evictCfg.configDir}/local/share/kscreen";
        }
        else {
          # Standard home directory structure
          "/home/tiebe/.local/share/kwalletd".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist/home/tiebe/.local/share/kwalletd";
          "/home/tiebe/.local/share/kscreen".source =
            config.lib.file.mkOutOfStoreSymlink
            "/persist/home/tiebe/.local/share/kscreen";
        };

      # Create the target directories in /persist before symlinks are set up
      home.activation.createPlasmaPersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          ${
          if evictCfg.enable
          then ''
            "/persist${evictCfg.configDir}/local/share/kwalletd" \
            "/persist${evictCfg.configDir}/local/share/kscreen"
          ''
          else ''
            "/persist/home/tiebe/.local/share/kwalletd" \
            "/persist/home/tiebe/.local/share/kscreen"
          ''
        }
      '';
    };
  };
}
