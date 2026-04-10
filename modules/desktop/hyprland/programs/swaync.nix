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
  swancCfg = config.tiebe.desktop.hyprland.programs.swaync;
in {
  options = {
    tiebe.desktop.hyprland.programs.swaync = {
      enable = mkEnableOption "SwayNC notification center for Hyprland";
    };
  };

  config = mkIf (cfg.enable && swancCfg.enable) {
    home-manager.users.tiebe = {
      services.swaync = {
        enable = true;
        settings = {
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          control-center-layer = "top";
          layer-shell = true;
          cssPriority = "application";
          control-center-margin-top = 10;
          control-center-margin-bottom = 10;
          control-center-margin-right = 10;
          control-center-margin-left = 0;
          control-center-width = 400;
          notification-icon-size = 64;
          notification-body-image-height = 100;
          notification-body-image-width = 200;
          timeout = 5;
          timeout-low = 3;
          timeout-critical = 0;
          fit-to-screen = true;
          notification-window-width = 400;
          keyboard-shortcuts = true;
          image-visibility = "when-available";
          transition-time = 200;
          hide-on-clear = false;
          hide-on-action = true;
          script-fail-notify = true;
          widgets = [
            "title"
            "dnd"
            "notifications"
            "mpris"
          ];
          widget-config = {
            title = {
              text = "Notifications";
              clear-all-button = true;
              button-text = "Clear";
            };
            dnd = {
              text = "Do Not Disturb";
            };
            mpris = {
              image-size = 96;
              image-radius = 12;
            };
          };
        };
        style = lib.mkForce ''
          /* Catppuccin Mocha */
          @define-color base #1e1e2e;
          @define-color mantle #181825;
          @define-color crust #11111b;
          @define-color surface0 #313244;
          @define-color surface1 #45475a;
          @define-color text #cdd6f4;
          @define-color subtext0 #a6adc8;
          @define-color mauve #cba6f7;
          @define-color red #f38ba8;
          @define-color green #a6e3a1;
          @define-color blue #89b4fa;

          * {
            font-family: "JetBrains Mono", "JetBrainsMono Nerd Font";
            font-size: 13px;
          }

          .notification-row {
            outline: none;
            margin: 4px;
          }

          .notification {
            background: @base;
            border: 2px solid @surface0;
            border-radius: 14px;
            padding: 8px;
            margin: 4px 8px;
          }

          .notification-content {
            margin: 8px;
          }

          .close-button {
            background: @surface0;
            color: @text;
            border-radius: 50%;
            margin: 4px;
            padding: 2px;
            min-width: 24px;
            min-height: 24px;
          }

          .close-button:hover {
            background: @red;
            color: @base;
          }

          .notification-default-action,
          .notification-action {
            border-radius: 10px;
            margin: 4px;
            padding: 6px;
            background: @surface0;
            color: @text;
          }

          .notification-default-action:hover,
          .notification-action:hover {
            background: @surface1;
          }

          .summary {
            color: @text;
            font-weight: bold;
          }

          .body {
            color: @subtext0;
          }

          .control-center {
            background: alpha(@base, 0.9);
            border: 2px solid @surface0;
            border-radius: 14px;
            padding: 10px;
          }

          .control-center-list {
            background: transparent;
          }

          .control-center .notification {
            background: @surface0;
          }

          .widget-title {
            color: @text;
            font-size: 16px;
            font-weight: bold;
            margin: 8px;
          }

          .widget-title > button {
            background: @mauve;
            color: @base;
            border-radius: 10px;
            padding: 4px 12px;
            font-weight: bold;
          }

          .widget-title > button:hover {
            background: @blue;
          }

          .widget-dnd {
            color: @text;
            margin: 8px;
          }

          .widget-dnd > switch {
            background: @surface0;
            border-radius: 10px;
          }

          .widget-dnd > switch:checked {
            background: @mauve;
          }

          .widget-dnd > switch slider {
            background: @text;
            border-radius: 50%;
          }

          .widget-mpris {
            background: @surface0;
            border-radius: 14px;
            margin: 8px;
            padding: 8px;
          }

          .widget-mpris-player {
            color: @text;
          }

          .widget-mpris-title {
            font-weight: bold;
          }

          .widget-mpris-subtitle {
            color: @subtext0;
          }
        '';
      };
    };
  };
}
