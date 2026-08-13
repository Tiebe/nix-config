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
        window_rule = [
          # Float dialogs and popups
          {
            match.title = "^(Open File)(.*)$";
            float = true;
          }
          {
            match.title = "^(Open Folder)(.*)$";
            float = true;
          }
          {
            match.title = "^(Save As)(.*)$";
            float = true;
          }
          {
            match.title = "^(Save File)(.*)$";
            float = true;
          }
          {
            match.title = "^(Confirm)(.*)$";
            float = true;
          }
          {
            match.title = "^(dialog)(.*)$";
            float = true;
          }
          {
            match.title = "^(About)(.*)$";
            float = true;
          }
          {
            match.title = "^(Preferences)(.*)$";
            float = true;
          }
          {
            match.title = "^(Settings)(.*)$";
            float = true;
          }
          {
            match.class = "^(file_progress)$";
            float = true;
          }
          {
            match.class = "^(confirm)$";
            float = true;
          }
          {
            match.class = "^(dialog)$";
            float = true;
          }
          {
            match.class = "^(download)$";
            float = true;
          }
          {
            match.class = "^(notification)$";
            float = true;
          }
          {
            match.class = "^(error)$";
            float = true;
          }
          {
            match.class = "^(splash)$";
            float = true;
          }
          {
            match.class = "^(confirmreset)$";
            float = true;
          }
          {
            match.class = "^(xdg-desktop-portal)(.*)$";
            float = true;
          }

          # Float system apps
          {
            match.class = "^(pavucontrol)$";
            float = true;
          }
          {
            match.class = "^(nm-connection-editor)$";
            float = true;
          }
          {
            match.class = "^(.blueman-manager-wrapped)$";
            float = true;
          }
          {
            match.class = "^(blueman-manager)$";
            float = true;
          }
          {
            match.class = "^(org.gnome.Calculator)$";
            float = true;
          }
          {
            match.class = "^(org.gnome.Nautilus)$";
            float = true;
          }
          {
            match.class = "^(org.gnome.Settings)$";
            float = true;
          }
          {
            match.class = "^(io.github.kaii_lb.Overskride)$";
            float = true;
          }
          {
            match.class = "^(org.kde.polkit-kde-authentication-agent-1)$";
            float = true;
          }
          {
            match.class = "^(polkit-gnome-authentication-agent-1)$";
            float = true;
          }

          # Float size constraints for system apps
          {
            match.class = "^(pavucontrol)$";
            size = [
              800
              600
            ];
          }
          {
            match.class = "^(nm-connection-editor)$";
            size = [
              800
              600
            ];
          }
          {
            match.class = "^(.blueman-manager-wrapped)$";
            size = [
              700
              500
            ];
          }
          {
            match.class = "^(blueman-manager)$";
            size = [
              700
              500
            ];
          }

          # Network/Bluetooth popups, anchored near the waybar icons
          {
            match.class = "^(org.gnome.Settings)$";
            size = [
              900
              650
            ];
          }
          {
            match.class = "^(org.gnome.Settings)$";
            move = [
              "monitor_w-920"
              "60"
            ];
          }
          {
            match.class = "^(io.github.kaii_lb.Overskride)$";
            size = [
              420
              560
            ];
          }
          {
            match.class = "^(io.github.kaii_lb.Overskride)$";
            move = [
              "monitor_w-440"
              "60"
            ];
          }

          # Opacity rules
          {
            match.class = "^(wezterm)$";
            opacity = "1.0 0.95";
          }
          {
            match.class = "^(org.wezfurlong.wezterm)$";
            opacity = "1.0 0.95";
          }
          {
            match.class = "^(Code)$";
            opacity = "0.95 0.85";
          }
          {
            match.class = "^(code-url-handler)$";
            opacity = "0.95 0.85";
          }
          {
            match.class = "^(firefox)$";
            opacity = "1.0 0.9";
          }
          {
            match.class = "^(chromium-browser)$";
            opacity = "1.0 0.9";
          }
          {
            match.class = "^(thunar)$";
            opacity = "0.9 0.8";
          }
          {
            match.class = "^(org.gnome.Nautilus)$";
            opacity = "0.9 0.8";
          }

          # Picture-in-picture
          {
            match.title = "^(Picture-in-Picture)$";
            float = true;
            pin = true;
            size = [
              480
              270
            ];
            # was "100%-490 50" under hyprlang's percent syntax; monitor_w/monitor_h
            # replace percent-relative positioning in the new expression syntax.
            move = [
              "monitor_w-490"
              "50"
            ];
            opacity = "1.0";
          }

          # wlogout
          {
            match.class = "^(wlogout)$";
            float = true;
            fullscreen = true;
          }

          # Inhibit idle for fullscreen apps
          {
            match.class = ".*";
            idle_inhibit = "fullscreen";
          }
        ];

        layer_rule = [
          {
            match.namespace = "waybar";
            blur = true;
          }
          {
            match.namespace = "waybar";
            ignore_alpha = 0.0;
          }
          {
            match.namespace = "rofi";
            blur = true;
          }
          {
            match.namespace = "rofi";
            ignore_alpha = 0.0;
          }
          {
            match.namespace = "swaync-control-center";
            blur = true;
          }
          {
            match.namespace = "swaync-notification-window";
            blur = true;
          }
          {
            match.namespace = "swaync-control-center";
            ignore_alpha = 0.0;
          }
          {
            match.namespace = "swaync-notification-window";
            ignore_alpha = 0.0;
          }
          {
            match.namespace = "logout_dialog";
            blur = true;
          }
        ];
      };
    };
  };
}
