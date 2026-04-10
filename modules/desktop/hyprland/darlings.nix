{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.hyprland;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: {
      # Persist hyprland config
      xdg.configFile."hypr".source =
        if evictCfg.enable
        then config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/hypr"
        else config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/hypr";

      # Persist waybar config
      xdg.configFile."waybar".source =
        if evictCfg.enable
        then config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/waybar"
        else config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/waybar";

      # Persist swaync config
      xdg.configFile."swaync".source =
        if evictCfg.enable
        then config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/swaync"
        else config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/swaync";

      # Create persist directories before symlinks
      home.activation.createHyprlandPersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          ${
          if evictCfg.enable
          then ''
            "/persist${evictCfg.configDir}/hypr" \
            "/persist${evictCfg.configDir}/waybar" \
            "/persist${evictCfg.configDir}/swaync"
          ''
          else ''
            "/persist/home/tiebe/.config/hypr" \
            "/persist/home/tiebe/.config/waybar" \
            "/persist/home/tiebe/.config/swaync"
          ''
        }
      '';
    };
  };
}
