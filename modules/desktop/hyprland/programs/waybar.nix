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
  waybarCfg = config.tiebe.desktop.hyprland.programs.waybar;

  # Brightness control script
  # - DDC/CI (ddcutil) for Gigabyte GS32Q and AOC Q27G2SG4
  # - Software gamma dimming (wl-gammarelay-rs) for HP 22cwa
  brightness-control = pkgs.writeShellScriptBin "brightness-control" ''
    STATE_FILE="/tmp/brightness-state"
    DDC_STEP=10

    # Initialize state if missing
    if [ ! -f "$STATE_FILE" ]; then
      echo "100" > "$STATE_FILE"
    fi

    get_brightness() {
      cat "$STATE_FILE"
    }

    set_brightness() {
      local val="$1"
      # Clamp 5-100
      [ "$val" -gt 100 ] && val=100
      [ "$val" -lt 5 ] && val=5
      echo "$val" > "$STATE_FILE"

      # DDC monitors (hardware brightness)
      # Detect buses at runtime — filter by Gigabyte GS32Q and AOC Q27G2SG4
      for bus in $(${pkgs.ddcutil}/bin/ddcutil detect --brief 2>/dev/null \
        | ${pkgs.gawk}/bin/awk '/^Display/{bus=""} /I2C bus:/{bus=$NF} /GS32Q|Q27G2SG4/{if(bus!="") print bus}'); do
        busnum="''${bus##*/dev/i2c-}"
        ${pkgs.ddcutil}/bin/ddcutil --bus "$busnum" setvcp 10 "$val" --noverify &
      done

      # HP monitor (software brightness via wl-gammarelay-rs over DBus)
      # Map 0-100 brightness to 0.0-1.0 gamma brightness
      local gamma_val
      gamma_val=$(${pkgs.bc}/bin/bc -l <<< "scale=2; $val / 100")
      busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d "$gamma_val" 2>/dev/null || true

      wait
    }

    case "''${1:-get}" in
      up)
        cur=$(get_brightness)
        set_brightness $((cur + DDC_STEP))
        ;;
      down)
        cur=$(get_brightness)
        set_brightness $((cur - DDC_STEP))
        ;;
      get)
        get_brightness
        ;;
      set)
        set_brightness "$2"
        ;;
      *)
        echo "Usage: brightness-control {up|down|get|set <value>}"
        exit 1
        ;;
    esac
  '';
in {
  options = {
    tiebe.desktop.hyprland.programs.waybar = {
      enable = mkEnableOption "Waybar for Hyprland";
    };
  };

  config = mkIf (cfg.enable && waybarCfg.enable) {
    home-manager.users.tiebe = {
      # Start wl-gammarelay-rs daemon for software brightness on HP monitor
      systemd.user.services.wl-gammarelay-rs = {
        Unit = {
          Description = "wl-gammarelay-rs — software brightness via Wayland gamma";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      home.packages = [brightness-control];

      programs.waybar = {
        enable = true;
        systemd = {
          enable = true;
          targets = ["hyprland-session.target"];
        };
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 40;
            margin-top = 6;
            margin-left = 10;
            margin-right = 10;
            spacing = 4;

            modules-left = [
              "hyprland/workspaces"
            ];

            modules-center = [
              "clock"
            ];

            modules-right = [
              "mpris"
              "custom/brightness"
              "cpu"
              "memory"
              "temperature"
              "pulseaudio"
              "battery"
              "tray"
              "custom/notification"
            ];

            "hyprland/workspaces" = {
              format = "{icon}";
              format-icons = {
                "1" = "1";
                "2" = "2";
                "3" = "3";
                "4" = "4";
                "5" = "5";
                "6" = "6";
                "7" = "7";
                "8" = "8";
                "9" = "9";
                "10" = "0";
                default = "";
              };
              on-click = "activate";
              all-outputs = true;
              sort-by-number = true;
            };

            clock = {
              format = "{:%H:%M}";
              format-alt = "{:%A, %B %d, %Y  %H:%M}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "year";
                mode-mon-col = 3;
                weeks-pos = "right";
                on-scroll = 1;
                format = {
                  months = "<span color='#cba6f7'><b>{}</b></span>";
                  days = "<span color='#cdd6f4'>{}</span>";
                  weeks = "<span color='#94e2d5'><b>W{}</b></span>";
                  weekdays = "<span color='#fab387'><b>{}</b></span>";
                  today = "<span color='#cba6f7'><b><u>{}</u></b></span>";
                };
              };
            };

            mpris = {
              format = "{player_icon} {dynamic}";
              format-paused = "{status_icon} <i>{dynamic}</i>";
              player-icons = {
                default = "";
                firefox = "";
                spotify = "";
              };
              status-icons = {
                paused = "";
              };
              dynamic-order = [
                "title"
                "artist"
              ];
              dynamic-len = 30;
              tooltip-format = "{player}: {title} - {artist} ({album})";
            };

            cpu = {
              format = " {usage}%";
              tooltip = true;
              interval = 5;
            };

            memory = {
              format = " {}%";
              tooltip-format = "{used:0.1f}G / {total:0.1f}G";
              interval = 5;
            };

            temperature = {
              format = " {temperatureC}°C";
              critical-threshold = 80;
              format-critical = " {temperatureC}°C";
              interval = 5;
            };

            pulseaudio = {
              format = "{icon} {volume}%";
              format-bluetooth = "{icon} {volume}%";
              format-muted = " muted";
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = [
                  ""
                  ""
                  ""
                ];
              };
              on-click = "pavucontrol";
              scroll-step = 5;
            };

            "custom/brightness" = {
              format = "☀ {}%";
              exec = "${brightness-control}/bin/brightness-control get";
              on-scroll-up = "${brightness-control}/bin/brightness-control up";
              on-scroll-down = "${brightness-control}/bin/brightness-control down";
              on-click = "${brightness-control}/bin/brightness-control set 100";
              on-click-right = "${brightness-control}/bin/brightness-control set 50";
              interval = 5;
              tooltip-format = "Brightness: {}% (scroll to adjust)";
            };

            battery = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
              tooltip-format = "{timeTo}";
            };

            tray = {
              spacing = 10;
              icon-size = 18;
            };

            "custom/notification" = {
              tooltip = false;
              format = "{icon}";
              format-icons = {
                notification = "<span foreground='red'><sup></sup></span>";
                none = "";
                dnd-notification = "<span foreground='red'><sup></sup></span>";
                dnd-none = "";
                inhibited-notification = "<span foreground='red'><sup></sup></span>";
                inhibited-none = "";
                dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
                dnd-inhibited-none = "";
              };
              return-type = "json";
              exec-if = "which swaync-client";
              exec = "swaync-client -swb";
              on-click = "swaync-client -t -sw";
              on-click-right = "swaync-client -d -sw";
              escape = true;
            };
          };
        };

        style = ''
          /* Catppuccin Mocha */
          @define-color base #1e1e2e;
          @define-color mantle #181825;
          @define-color crust #11111b;
          @define-color surface0 #313244;
          @define-color surface1 #45475a;
          @define-color surface2 #585b70;
          @define-color overlay0 #6c7086;
          @define-color overlay1 #7f849c;
          @define-color text #cdd6f4;
          @define-color subtext0 #a6adc8;
          @define-color subtext1 #bac2de;
          @define-color mauve #cba6f7;
          @define-color red #f38ba8;
          @define-color peach #fab387;
          @define-color yellow #f9e2af;
          @define-color green #a6e3a1;
          @define-color teal #94e2d5;
          @define-color blue #89b4fa;
          @define-color lavender #b4befe;
          @define-color flamingo #f2cdcd;
          @define-color rosewater #f5e0dc;

          * {
            font-family: "JetBrains Mono", "JetBrainsMono Nerd Font";
            font-size: 13px;
            min-height: 0;
            border: none;
            border-radius: 0;
          }

          window#waybar {
            background: alpha(@base, 0.7);
            border-radius: 14px;
            border: 2px solid alpha(@surface0, 0.6);
          }

          tooltip {
            background: @base;
            border: 2px solid @mauve;
            border-radius: 10px;
          }

          tooltip label {
            color: @text;
          }

          #workspaces {
            margin-left: 8px;
          }

          #workspaces button {
            color: @overlay1;
            padding: 0 8px;
            border-radius: 10px;
            margin: 4px 2px;
            transition: all 0.15s ease;
          }

          #workspaces button.active {
            color: @base;
            background: @mauve;
          }

          #workspaces button:hover {
            color: @text;
            background: @surface1;
          }

          #clock {
            color: @text;
            font-weight: bold;
          }

          #mpris {
            color: @mauve;
          }

          #cpu {
            color: @blue;
          }

          #memory {
            color: @teal;
          }

          #temperature {
            color: @peach;
          }

          #temperature.critical {
            color: @red;
          }

          #pulseaudio {
            color: @lavender;
          }

          #pulseaudio.muted {
            color: @overlay0;
          }

          #custom-brightness {
            color: @yellow;
          }

          #battery {
            color: @green;
          }

          #battery.charging {
            color: @green;
          }

          #battery.warning:not(.charging) {
            color: @yellow;
          }

          #battery.critical:not(.charging) {
            color: @red;
            animation: blink 0.5s linear infinite alternate;
          }

          @keyframes blink {
            to {
              color: @text;
            }
          }

          #tray {
            margin-right: 4px;
          }

          #tray > .passive {
            -gtk-icon-effect: dim;
          }

          #tray > .needs-attention {
            -gtk-icon-effect: highlight;
          }

          #custom-notification {
            color: @text;
            margin-right: 8px;
          }

          /* Module spacing */
          #mpris,
          #custom-brightness,
          #cpu,
          #memory,
          #temperature,
          #pulseaudio,
          #battery,
          #tray,
          #custom-notification {
            padding: 0 10px;
            margin: 4px 0;
          }
        '';
      };
    };
  };
}
