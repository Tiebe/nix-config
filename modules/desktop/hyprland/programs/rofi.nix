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
  rofiCfg = config.tiebe.desktop.hyprland.programs.rofi;
in {
  options = {
    tiebe.desktop.hyprland.programs.rofi = {
      enable = mkEnableOption "rofi for Hyprland";
    };
  };

  config = mkIf (cfg.enable && rofiCfg.enable) {
    # Enable the existing rofi module (rofi has native Wayland support)
    tiebe.desktop.apps.rofi.enable = true;
  };
}
