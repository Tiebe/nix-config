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
  wlogoutCfg = config.tiebe.desktop.hyprland.programs.wlogout;
in {
  options = {
    tiebe.desktop.hyprland.programs.wlogout = {
      enable = mkEnableOption "wlogout for Hyprland";
    };
  };

  config = mkIf (cfg.enable && wlogoutCfg.enable) {
    home-manager.users.tiebe = {
      programs.wlogout = {
        enable = true;
        layout = [
          {
            label = "lock";
            action = "hyprlock";
            text = "Lock";
            keybind = "l";
          }
          {
            label = "logout";
            action = "hyprctl dispatch exit";
            text = "Logout";
            keybind = "e";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
          }
          {
            label = "hibernate";
            action = "systemctl hibernate";
            text = "Hibernate";
            keybind = "h";
          }
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
          {
            label = "reboot";
            action = "systemctl reboot";
            text = "Reboot";
            keybind = "r";
          }
        ];
        style = ''
          /* Catppuccin Mocha */
          @define-color base #1e1e2e;
          @define-color mantle #181825;
          @define-color surface0 #313244;
          @define-color text #cdd6f4;
          @define-color subtext0 #a6adc8;
          @define-color mauve #cba6f7;
          @define-color red #f38ba8;
          @define-color peach #fab387;
          @define-color yellow #f9e2af;
          @define-color green #a6e3a1;
          @define-color blue #89b4fa;

          * {
            font-family: "JetBrains Mono", "JetBrainsMono Nerd Font";
            background-image: none;
          }

          window {
            background-color: alpha(@base, 0.85);
          }

          button {
            color: @text;
            background-color: @surface0;
            border: 2px solid @surface0;
            border-radius: 20px;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
            margin: 10px;
            transition: all 0.15s ease;
          }

          button:focus,
          button:active,
          button:hover {
            outline-style: none;
          }

          button:hover {
            background-color: alpha(@mauve, 0.2);
            border-color: @mauve;
          }

          #lock {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
          }

          #lock:hover {
            border-color: @blue;
            background-color: alpha(@blue, 0.2);
          }

          #logout {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
          }

          #logout:hover {
            border-color: @mauve;
            background-color: alpha(@mauve, 0.2);
          }

          #suspend {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"));
          }

          #suspend:hover {
            border-color: @yellow;
            background-color: alpha(@yellow, 0.2);
          }

          #hibernate {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"));
          }

          #hibernate:hover {
            border-color: @peach;
            background-color: alpha(@peach, 0.2);
          }

          #shutdown {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
          }

          #shutdown:hover {
            border-color: @red;
            background-color: alpha(@red, 0.2);
          }

          #reboot {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
          }

          #reboot:hover {
            border-color: @green;
            background-color: alpha(@green, 0.2);
          }
        '';
      };
    };
  };
}
