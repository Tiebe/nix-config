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
  bindsCfg = config.tiebe.desktop.hyprland.binds;
  monitorBrightnessCfg = config.tiebe.desktop.hyprland.binds.monitorBrightness;

  # Scripts
  screenshotArea = pkgs.writeShellScriptBin "screenshot-area" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.libnotify}/bin/notify-send "Screenshot" "Area captured to clipboard" -t 2000
  '';

  screenshotFull = pkgs.writeShellScriptBin "screenshot-full" ''
    ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.libnotify}/bin/notify-send "Screenshot" "Screen captured to clipboard" -t 2000
  '';

  clipboardHistory = pkgs.writeShellScriptBin "clipboard-history" ''
    ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu -p "Clipboard" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  # Lua bind helpers.
  # `keys` is a plain key-combo string, `dispatcher` is a raw Lua expression
  # string (e.g. "hl.dsp.window.close()"), `flags` is an optional bind-flags attrset.
  bind = keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
    ];
  };
  bindFlags = keys: dispatcher: flags: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
      flags
    ];
  };
  mkExec = cmd: "hl.dsp.exec_cmd(${builtins.toJSON cmd})";

  # Per-monitor brightness control script.
  # Usage: brightness-control <monitor-name> <action> [value]
  # - Auto-detects DDC vs software per monitor
  # - DDC monitors → ddcutil hardware brightness
  # - Non-DDC monitors → wl-gammarelay-rs per-output software dimming
  brightnessControl = pkgs.writeShellScriptBin "brightness-control" ''
    set -uo pipefail

    MONITOR="''${1:?Usage: brightness-control <monitor-name> <action> [value]}"
    ACTION="''${2:-get}"
    VALUE="''${3:-}"
    STATE_FILE="/tmp/brightness-state-$MONITOR"
    CACHE_FILE="/tmp/brightness-ddc-cache"
    CACHE_MAX_AGE=600 # 10 minutes
    STEP=10

    # Initialize state if missing
    [[ -f "$STATE_FILE" ]] || echo 100 > "$STATE_FILE"

    # Detect all DDC-capable monitors via ddcutil
    # Cache format: bus_number:connector_name per line
    refresh_cache() {
      local bus="" connector="" valid=0
      : > "$CACHE_FILE"
      while IFS= read -r line; do
        if [[ "$line" =~ ^Display\ [0-9]+ ]]; then
          valid=1
        elif [[ "$line" =~ ^Invalid\ display ]]; then
          valid=0
        fi
        if [[ "$line" =~ I2C\ bus:.*i2c-([0-9]+) ]]; then
          bus="''${BASH_REMATCH[1]}"
        fi
        if [[ "$line" =~ DRM[_\ ]connector:.*card[0-9]+-([A-Za-z0-9-]+) ]]; then
          connector="''${BASH_REMATCH[1]}"
          [[ -n "$bus" && "$valid" == "1" ]] && echo "$bus:$connector" >> "$CACHE_FILE"
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

      # Check if this monitor has DDC
      local ddc_bus=""
      while IFS=: read -r bus connector; do
        if [[ "$connector" == "$MONITOR" ]]; then
          ddc_bus="$bus"
          break
        fi
      done < "$CACHE_FILE"

      if [[ -n "$ddc_bus" ]]; then
        # DDC monitor → hardware brightness
        ${pkgs.ddcutil}/bin/ddcutil --bus "$ddc_bus" setvcp 10 "$val" --noverify &
      else
        # Non-DDC → software brightness via wl-gammarelay-rs per-output DBus
        local gamma_val dbus_path
        gamma_val=$(${pkgs.bc}/bin/bc -l <<< "scale=2; $val / 100")
        dbus_path="/outputs/''${MONITOR//-/_}"
        busctl --user set-property rs.wl-gammarelay "$dbus_path" \
          rs.wl.gammarelay Brightness d "$gamma_val" 2>/dev/null || true
      fi

      wait
    }

    case "$ACTION" in
      up)   cur=$(get_brightness); set_brightness $((cur + STEP)) ;;
      down) cur=$(get_brightness); set_brightness $((cur - STEP)) ;;
      get)  get_brightness ;;
      set)  set_brightness "''${VALUE:?Usage: brightness-control <monitor> set <0-100>}" ;;
      refresh) refresh_cache; echo "DDC cache refreshed" ;;
      *)    echo "Usage: brightness-control <monitor-name> {up|down|get|set <value>|refresh}"; exit 1 ;;
    esac
  '';

  # Fn-key wrapper: applies brightness-control to every currently connected
  # monitor (queried live from Hyprland, no hardcoded connector names).
  brightnessFn = pkgs.writeShellScriptBin "brightness-fn" ''
    set -uo pipefail
    ACTION="''${1:?Usage: brightness-fn up|down}"
    for m in $(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[].name'); do
      ${brightnessControl}/bin/brightness-control "$m" "$ACTION" &
    done
    wait
  '';

  brightnessUpCmd =
    if monitorBrightnessCfg.enable
    then "${brightnessFn}/bin/brightness-fn up"
    else "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
  brightnessDownCmd =
    if monitorBrightnessCfg.enable
    then "${brightnessFn}/bin/brightness-fn down"
    else "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
in {
  options = {
    tiebe.desktop.hyprland.binds = {
      enable = mkEnableOption "Hyprland keybindings";
      monitorBrightness.enable = mkEnableOption "multi-monitor brightness Fn keys (DDC hardware brightness on DDC-capable monitors, software gamma dimming on the rest)";
    };
  };

  config = mkIf (cfg.enable && bindsCfg.enable) {
    home-manager.users.tiebe = {
      home.packages =
        [
          screenshotArea
          screenshotFull
          clipboardHistory
        ]
        ++ lib.optionals monitorBrightnessCfg.enable [
          brightnessControl
          brightnessFn
        ];

      # wl-gammarelay-rs daemon for per-output software brightness (non-DDC monitors)
      systemd.user.services.wl-gammarelay-rs = mkIf monitorBrightnessCfg.enable {
        Unit = {
          Description = "wl-gammarelay-rs — per-output software brightness via Wayland gamma";
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

      wayland.windowManager.hyprland.settings = {
        bind = [
          # Application launchers
          (bind "SUPER + SHIFT + RETURN" (mkExec "rofi-launcher"))
          (bind "SUPER + RETURN" (mkExec "wezterm"))
          (bind "SUPER + Q" "hl.dsp.window.close()")
          (bind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
          (bind "SUPER + SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'') # maximize
          (bind "SUPER + V" "hl.dsp.window.float()")
          (bind "SUPER + P" "hl.dsp.window.pseudo()") # dwindle
          (bind "SUPER + S" ''hl.dsp.layout("togglesplit")'') # dwindle

          # Lock / logout
          (bind "SUPER + L" (mkExec "hyprlock"))
          (bind "SUPER + M" (mkExec "wlogout"))

          # Screenshots
          (bind "Print" (mkExec "screenshot-full"))
          (bind "SUPER + SHIFT + S" (mkExec "screenshot-area"))

          # Clipboard history
          (bind "SUPER + SHIFT + V" (mkExec "clipboard-history"))

          # Notification center
          (bind "SUPER + N" (mkExec "swaync-client -t -sw"))

          # Focus movement
          (bind "SUPER + left" ''hl.dsp.focus({ direction = "left" })'')
          (bind "SUPER + right" ''hl.dsp.focus({ direction = "right" })'')
          (bind "SUPER + up" ''hl.dsp.focus({ direction = "up" })'')
          (bind "SUPER + down" ''hl.dsp.focus({ direction = "down" })'')
          (bind "SUPER + H" ''hl.dsp.focus({ direction = "left" })'')
          (bind "SUPER + J" ''hl.dsp.focus({ direction = "down" })'')
          (bind "SUPER + K" ''hl.dsp.focus({ direction = "up" })'')

          # Window movement
          (bind "SUPER + SHIFT + left" ''hl.dsp.window.move({ direction = "left" })'')
          (bind "SUPER + SHIFT + right" ''hl.dsp.window.move({ direction = "right" })'')
          (bind "SUPER + SHIFT + up" ''hl.dsp.window.move({ direction = "up" })'')
          (bind "SUPER + SHIFT + down" ''hl.dsp.window.move({ direction = "down" })'')
          (bind "SUPER + SHIFT + H" ''hl.dsp.window.move({ direction = "left" })'')
          (bind "SUPER + SHIFT + J" ''hl.dsp.window.move({ direction = "down" })'')
          (bind "SUPER + SHIFT + K" ''hl.dsp.window.move({ direction = "up" })'')
          (bind "SUPER + SHIFT + L" ''hl.dsp.window.move({ direction = "right" })'')

          # Workspace switching
          (bind "SUPER + 1" ''hl.dsp.focus({ workspace = 1 })'')
          (bind "SUPER + 2" ''hl.dsp.focus({ workspace = 2 })'')
          (bind "SUPER + 3" ''hl.dsp.focus({ workspace = 3 })'')
          (bind "SUPER + 4" ''hl.dsp.focus({ workspace = 4 })'')
          (bind "SUPER + 5" ''hl.dsp.focus({ workspace = 5 })'')
          (bind "SUPER + 6" ''hl.dsp.focus({ workspace = 6 })'')
          (bind "SUPER + 7" ''hl.dsp.focus({ workspace = 7 })'')
          (bind "SUPER + 8" ''hl.dsp.focus({ workspace = 8 })'')
          (bind "SUPER + 9" ''hl.dsp.focus({ workspace = 9 })'')
          (bind "SUPER + 0" ''hl.dsp.focus({ workspace = 10 })'')

          # Move to workspace
          (bind "SUPER + SHIFT + 1" ''hl.dsp.window.move({ workspace = 1 })'')
          (bind "SUPER + SHIFT + 2" ''hl.dsp.window.move({ workspace = 2 })'')
          (bind "SUPER + SHIFT + 3" ''hl.dsp.window.move({ workspace = 3 })'')
          (bind "SUPER + SHIFT + 4" ''hl.dsp.window.move({ workspace = 4 })'')
          (bind "SUPER + SHIFT + 5" ''hl.dsp.window.move({ workspace = 5 })'')
          (bind "SUPER + SHIFT + 6" ''hl.dsp.window.move({ workspace = 6 })'')
          (bind "SUPER + SHIFT + 7" ''hl.dsp.window.move({ workspace = 7 })'')
          (bind "SUPER + SHIFT + 8" ''hl.dsp.window.move({ workspace = 8 })'')
          (bind "SUPER + SHIFT + 9" ''hl.dsp.window.move({ workspace = 9 })'')
          (bind "SUPER + SHIFT + 0" ''hl.dsp.window.move({ workspace = 10 })'')

          # Special workspace (scratchpad)
          (bind "SUPER + grave" ''hl.dsp.workspace.toggle_special("magic")'')
          (bind "SUPER + SHIFT + grave" ''hl.dsp.window.move({ workspace = "special:magic" })'')

          # Scroll through workspaces
          (bind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
          (bind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

          # Tab through recent workspaces
          (bind "SUPER + Tab" ''hl.dsp.focus({ workspace = "previous" })'')

          # Resize (hold to repeat)
          (bindFlags "SUPER + CTRL + left" ''hl.dsp.window.resize({ x = -20, y = 0, relative = true })'' {repeating = true;})
          (bindFlags "SUPER + CTRL + right" ''hl.dsp.window.resize({ x = 20, y = 0, relative = true })'' {repeating = true;})
          (bindFlags "SUPER + CTRL + up" ''hl.dsp.window.resize({ x = 0, y = -20, relative = true })'' {repeating = true;})
          (bindFlags "SUPER + CTRL + down" ''hl.dsp.window.resize({ x = 0, y = 20, relative = true })'' {repeating = true;})
          (bindFlags "SUPER + CTRL + H" ''hl.dsp.window.resize({ x = -20, y = 0, relative = true })'' {repeating = true;})
          (bindFlags "SUPER + CTRL + L" ''hl.dsp.window.resize({ x = 20, y = 0, relative = true })'' {repeating = true;})
          (bindFlags "SUPER + CTRL + K" ''hl.dsp.window.resize({ x = 0, y = -20, relative = true })'' {repeating = true;})
          (bindFlags "SUPER + CTRL + J" ''hl.dsp.window.resize({ x = 0, y = 20, relative = true })'' {repeating = true;})

          # Mouse binds
          (bindFlags "SUPER + mouse:272" "hl.dsp.window.drag()" {mouse = true;})
          (bindFlags "SUPER + mouse:273" "hl.dsp.window.resize()" {mouse = true;})

          # Media controls (locked binds, work even when locked)
          (bindFlags "XF86AudioMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'' {locked = true;})
          (bindFlags "XF86AudioMicMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'' {locked = true;})
          (bindFlags "XF86AudioPlay" (mkExec "${pkgs.playerctl}/bin/playerctl play-pause") {locked = true;})
          (bindFlags "XF86AudioNext" (mkExec "${pkgs.playerctl}/bin/playerctl next") {locked = true;})
          (bindFlags "XF86AudioPrev" (mkExec "${pkgs.playerctl}/bin/playerctl previous") {locked = true;})
          (bindFlags "XF86AudioStop" (mkExec "${pkgs.playerctl}/bin/playerctl stop") {locked = true;})

          # Locked + repeat binds
          (bindFlags "XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'' {
            locked = true;
            repeating = true;
          })
          (bindFlags "XF86AudioLowerVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'' {
            locked = true;
            repeating = true;
          })
          (bindFlags "XF86MonBrightnessUp" (mkExec brightnessUpCmd) {
            locked = true;
            repeating = true;
          })
          (bindFlags "XF86MonBrightnessDown" (mkExec brightnessDownCmd) {
            locked = true;
            repeating = true;
          })
        ];
      };
    };
  };
}
