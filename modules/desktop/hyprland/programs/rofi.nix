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
      enable = mkEnableOption "rofi-wayland for Hyprland";
    };
  };

  config = mkIf (cfg.enable && rofiCfg.enable) {
    # Enable the existing rofi module and override the package to wayland
    tiebe.desktop.apps.rofi.enable = true;

    home-manager.users.tiebe = {
      programs.rofi.package = lib.mkForce pkgs.rofi-wayland;
    };
  };
}
