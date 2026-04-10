{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.hyprland;
  animCfg = config.tiebe.desktop.hyprland.animations;
in {
  options = {
    tiebe.desktop.hyprland.animations = {
      enable = mkEnableOption "Hyprland animations";
    };
  };

  config = mkIf (cfg.enable && animCfg.enable) {
    home-manager.users.tiebe = {
      wayland.windowManager.hyprland.settings = {
        animations = {
          enabled = true;
          # Snappy bezier curves
          bezier = [
            "snappy, 0.05, 0.9, 0.1, 1.0"
            "snappyFade, 0.2, 0.8, 0.2, 1.0"
            "snappyMove, 0.05, 0.7, 0.1, 1.0"
            "overshot, 0.05, 0.9, 0.1, 1.05"
          ];
          animation = [
            "windows, 1, 3, snappy, popin 80%"
            "windowsOut, 1, 3, snappyFade, popin 80%"
            "windowsMove, 1, 2, snappyMove"
            "fade, 1, 3, snappyFade"
            "workspaces, 1, 3, snappy, slide"
            "specialWorkspace, 1, 3, snappy, slidevert"
            "border, 1, 5, default"
            "borderangle, 1, 5, default"
            "layers, 1, 2, snappyFade, fade"
          ];
        };
      };
    };
  };
}
