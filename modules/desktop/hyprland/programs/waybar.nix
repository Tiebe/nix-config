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
  # - Auto-detects DDC-capable monitors via ddcutil → hardware brightness
  # - Non-DDC monitors get per-output software dimming via wl-gammarelay-rs
  # - Works on any host/monitor combination without hardcoded model names
  brightness-control = pkgs.writeShellScriptBin "brightness-control" ''
    set -uo pipefail

    STATE_FILE="/tmp/brightness-state"
    CACHE_FILE="/tmp/brightness-ddc-cache"
    CACHE_MAX_AGE=600 # 10 minutes
    STEP=10

    # Initialize state if missing
    [[ -f "$STATE_FILE" ]] || echo 100 > "$STATE_FILE"

    # Detect all DDC-capable monitors via ddcutil
    # Parses I2C bus numbers and DRM connector names (e.g. DP-1, HDMI-A-1)
    # Cache format: bus_number:connector_name per line
    refresh_cache() {
      local bus="" connector=""
      : > "$CACHE_FILE"
      while IFS= read -r line; do
        if [[ "$line" =~ I2C\ bus:.*i2c-([0-9]+) ]]; then
          bus="''${BASH_REMATCH[1]}"
        fi
        if [[ "$line" =~ DRM\ connector:.*card[0-9]+-([A-Za-z0-9-]+) ]]; then
          connector="''${BASH_REMATCH[1]}"
          [[ -n "$bus" ]] && echo "$bus:$connector" >> "$CACHE_FILE"
          bus="" connector=""
        fi
      done < <(${pkgs.ddcutil}/bin/ddcutil detect 2>/dev/null)
    }

    ensure_cache() {
      if [[ ! -f "$CACHE_FILE" ]]; then
        refresh_cache
        return
      fi
      local now age
      now=$(date +%s)
      age=$(( now - $(stat -c %Y "$CACHE_FILE") ))
      (( age > CACHE_MAX_AGE )) && refresh_cache
    }

    get_brightness() { cat "$STATE_FILE"; }

    set_brightness() {
      local val=$1
      (( val > 100 )) && val=100
      (( val < 5 )) && val=5
      echo "$val" > "$STATE_FILE"

      ensure_cache

      # Build set of DDC-capable connectors & send hardware brightness
      declare -A ddc_connectors=()
      while IFS=: read -r bus connector; do
        [[ -z "$bus" ]] && continue
        ddc_connectors["$connector"]=1
        ${pkgs.ddcutil}/bin/ddcutil --bus "$bus" setvcp 10 "$val" --noverify &
      done < "$CACHE_FILE"

      # Software brightness for non-DDC outputs via wl-gammarelay-rs per-output DBus
      local gamma_val
      gamma_val=$(${pkgs.bc}/bin/bc -l <<< "scale=2; $val / 100")

      while IFS= read -r output; do
        [[ -z "$output" ]] && continue
        # Skip outputs that have DDC — they're handled by ddcutil above
        if [[ -z "''${ddc_connectors[$output]+x}" ]]; then
          # wl-gammarelay-rs DBus path: /outputs/<name> with dashes replaced by underscores
          local dbus_path="/outputs/''${output//-/_}"
          busctl --user set-property rs.wl-gammarelay "$dbus_path" \
            rs.wl.gammarelay Brightness d "$gamma_val" 2>/dev/null || true
        fi
      done < <(hyprctl monitors -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[].name')

      wait
    }

    case "''${1:-get}" in
      up)   cur=$(get_brightness); set_brightness $((cur + STEP)) ;;
      down) cur=$(get_brightness); set_brightness $((cur - STEP)) ;;
      get)  get_brightness ;;
      set)  set_brightness "''${2:?Usage: brightness-control set <0-100>}" ;;
      refresh) refresh_cache; echo "DDC cache refreshed" ;;
      *)    echo "Usage: brightness-control {up|down|get|set <value>|refresh}"; exit 1 ;;
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
      # Start wl-gammarelay-rs daemon for per-output software brightness (non-DDC monitors)
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
