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
  wrCfg = config.tiebe.desktop.hyprland.windowrules;
in {
  options = {
    tiebe.desktop.hyprland.windowrules = {
      enable = mkEnableOption "Hyprland window rules";
    };
  };

  config = mkIf (cfg.enable && wrCfg.enable) {
    home-manager.users.tiebe = {
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          # Float dialogs and popups
          "match:title ^(Open File)(.*)$, float on"
          "match:title ^(Open Folder)(.*)$, float on"
          "match:title ^(Save As)(.*)$, float on"
          "match:title ^(Save File)(.*)$, float on"
          "match:title ^(Confirm)(.*)$, float on"
          "match:title ^(dialog)(.*)$, float on"
          "match:title ^(About)(.*)$, float on"
          "match:title ^(Preferences)(.*)$, float on"
          "match:title ^(Settings)(.*)$, float on"
          "match:class ^(file_progress)$, float on"
          "match:class ^(confirm)$, float on"
          "match:class ^(dialog)$, float on"
          "match:class ^(download)$, float on"
          "match:class ^(notification)$, float on"
          "match:class ^(error)$, float on"
          "match:class ^(splash)$, float on"
          "match:class ^(confirmreset)$, float on"
          "match:class ^(xdg-desktop-portal)(.*)$, float on"

          # Float system apps
          "match:class ^(pavucontrol)$, float on"
          "match:class ^(nm-connection-editor)$, float on"
          "match:class ^(.blueman-manager-wrapped)$, float on"
          "match:class ^(blueman-manager)$, float on"
          "match:class ^(org.gnome.Calculator)$, float on"
          "match:class ^(org.gnome.Nautilus)$, float on"
          "match:class ^(org.gnome.Settings)$, float on"
          "match:class ^(org.kde.polkit-kde-authentication-agent-1)$, float on"
          "match:class ^(polkit-gnome-authentication-agent-1)$, float on"

          # Float size constraints for system apps
          "match:class ^(pavucontrol)$, size 800 600"
          "match:class ^(nm-connection-editor)$, size 800 600"
          "match:class ^(.blueman-manager-wrapped)$, size 700 500"
          "match:class ^(blueman-manager)$, size 700 500"

          # Opacity rules
          "match:class ^(wezterm)$, opacity 1.0 0.95"
          "match:class ^(org.wezfurlong.wezterm)$, opacity 1.0 0.95"
          "match:class ^(Code)$, opacity 0.95 0.85"
          "match:class ^(code-url-handler)$, opacity 0.95 0.85"
          "match:class ^(firefox)$, opacity 1.0 0.9"
          "match:class ^(chromium-browser)$, opacity 1.0 0.9"
          "match:class ^(thunar)$, opacity 0.9 0.8"
          "match:class ^(org.gnome.Nautilus)$, opacity 0.9 0.8"

          # Picture-in-picture
          "match:title ^(Picture-in-Picture)$, float on, pin on, size 480 270, move 100%-490 50, opacity 1.0"

          # wlogout
          "match:class ^(wlogout)$, float on, fullscreen on"

          # Inhibit idle for fullscreen apps
          "match:class .*, idle_inhibit fullscreen"
        ];

        layerrule = [
          "blur on, match:namespace waybar"
          "ignore_alpha 0.0, match:namespace waybar"
          "blur on, match:namespace rofi"
          "ignore_alpha 0.0, match:namespace rofi"
          "blur on, match:namespace swaync-control-center"
          "blur on, match:namespace swaync-notification-window"
          "ignore_alpha 0.0, match:namespace swaync-control-center"
          "ignore_alpha 0.0, match:namespace swaync-notification-window"
          "blur on, match:namespace logout_dialog"
        ];
      };
    };
  };
}
