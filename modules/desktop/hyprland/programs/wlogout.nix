{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.hyprland.programs.wlogout;
in {
  options = {
    tiebe.desktop.hyprland.programs.wlogout = {
      enable = mkEnableOption "wlogout";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      programs.wlogout = {
        enable = true;
        layout = [
          {
            label = "shutdown";
            action = "sleep 1; systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
          {
            "label" = "reboot";
            "action" = "sleep 1; systemctl reboot";
            "text" = "Reboot";
            "keybind" = "r";
          }
          {
            "label" = "logout";
            "action" = "sleep 1; hyprctl dispatch exit";
            "text" = "Exit";
            "keybind" = "e";
          }
          {
            "label" = "lock";
            "action" = "sleep 1; hyprlock";
            "text" = "Lock";
            "keybind" = "l";
          }
        ];
      };
    };
  };
}
