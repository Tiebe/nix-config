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
        windowrulev2 = [
          # Float dialogs and popups
          "float, title:^(Open File)(.*)$"
          "float, title:^(Open Folder)(.*)$"
          "float, title:^(Save As)(.*)$"
          "float, title:^(Save File)(.*)$"
          "float, title:^(Confirm)(.*)$"
          "float, title:^(dialog)(.*)$"
          "float, title:^(About)(.*)$"
          "float, title:^(Preferences)(.*)$"
          "float, title:^(Settings)(.*)$"
          "float, class:^(file_progress)$"
          "float, class:^(confirm)$"
          "float, class:^(dialog)$"
          "float, class:^(download)$"
          "float, class:^(notification)$"
          "float, class:^(error)$"
          "float, class:^(splash)$"
          "float, class:^(confirmreset)$"
          "float, class:^(xdg-desktop-portal)(.*)$"

          # Float system apps
          "float, class:^(pavucontrol)$"
          "float, class:^(nm-connection-editor)$"
          "float, class:^(.blueman-manager-wrapped)$"
          "float, class:^(blueman-manager)$"
          "float, class:^(org.gnome.Calculator)$"
          "float, class:^(org.gnome.Nautilus)$"
          "float, class:^(org.gnome.Settings)$"
          "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
          "float, class:^(polkit-gnome-authentication-agent-1)$"

          # Float size constraints for system apps
          "size 800 600, class:^(pavucontrol)$"
          "size 800 600, class:^(nm-connection-editor)$"
          "size 700 500, class:^(.blueman-manager-wrapped)$"
          "size 700 500, class:^(blueman-manager)$"

          # Opacity rules
          "opacity 0.95 0.85, class:^(wezterm)$"
          "opacity 0.95 0.85, class:^(org.wezfurlong.wezterm)$"
          "opacity 0.95 0.85, class:^(Code)$"
          "opacity 0.95 0.85, class:^(code-url-handler)$"
          "opacity 1.0 0.9, class:^(firefox)$"
          "opacity 1.0 0.9, class:^(chromium-browser)$"
          "opacity 0.9 0.8, class:^(thunar)$"
          "opacity 0.9 0.8, class:^(org.gnome.Nautilus)$"

          # Picture-in-picture
          "float, title:^(Picture-in-Picture)$"
          "pin, title:^(Picture-in-Picture)$"
          "size 480 270, title:^(Picture-in-Picture)$"
          "move 100%-490 50, title:^(Picture-in-Picture)$"
          "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"

          # wlogout
          "float, class:^(wlogout)$"
          "fullscreen, class:^(wlogout)$"

          # Inhibit idle for fullscreen apps
          "idleinhibit fullscreen, class:^(.*)$"

          # Layer rules for rofi, waybar, etc.
        ];

        layerrule = [
          "blur, waybar"
          "ignorezero, waybar"
          "blur, rofi"
          "ignorezero, rofi"
          "blur, swaync-control-center"
          "blur, swaync-notification-window"
          "ignorezero, swaync-control-center"
          "ignorezero, swaync-notification-window"
          "blur, logout_dialog"
        ];
      };
    };
  };
}
