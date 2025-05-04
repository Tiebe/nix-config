{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.hyprland.greetd;
in
{
  options = {
    tiebe.desktop.hyprland.greetd = {
      enable = mkEnableOption "greetd";
    };
  };

  config = mkIf cfg.enable {
   services.greetd = {
    enable = true;
    vt = 1;
    settings = {
      default_session = {
        user = "tiebe";
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
      };
    };
  };   
  };
}