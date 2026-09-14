{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.hyprland;
  pickerCfg = config.tiebe.desktop.hyprland.sharePicker;

  hyprPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};

  # Same Hyprland build the session runs, so hyprctl talks to the compositor's IPC.
  hyprctl = "${hyprPkgs.hyprland}/bin/hyprctl";

  # Stock Qt picker: used whenever no game is up, so "share something else" and
  # "no game running" both behave exactly like they do today.
  interactivePicker = "${hyprPkgs.xdg-desktop-portal-hyprland}/bin/hyprland-share-picker";

  # On Wayland the *portal* decides what gets captured: Discord only calls
  # getDisplayMedia, xdph runs a picker binary and whatever that binary prints is
  # the capture source. Replacing the picker is therefore the only place where
  # "share the game I am playing" can be decided.
  #
  # xdph contract (src/shared/ScreencopyShared.cpp @ xdph 1.4.1):
  #   * argv may contain --allow-token. We never emit the `r` flag: a restore
  #     token pins the *window class* of the first share and xdph then replays it
  #     without prompting, which would hijack every later share.
  #   * XDPH_WINDOW_SHARING_LIST holds one record per capturable toplevel:
  #       <handle>[HC>]<class>[HT>]<title>[HE>]<hyprland window address>[HA>]
  #     where <handle> is the low 32 bits of the toplevel handle - the only id
  #     xdph accepts - and <hyprland window address> is the decimal form of the
  #     address `hyprctl clients` reports in hex.
  #   * stdout must contain `[SELECTION]<flags>/window:<handle>`; without it xdph
  #     treats the share as cancelled.
  picker = pkgs.writeShellApplication {
    name = "hyprland-game-share-picker";
    runtimeInputs = [pkgs.gawk pkgs.jq];
    text = ''
      # Quoted assignments, not inline interpolation: these store paths contain
      # `+date=`, which shellcheck reads as an assignment in command position.
      hyprctl='${hyprctl}'
      interactive_picker='${interactivePicker}'

      fallback() {
        exec "$interactive_picker" "$@"
      }

      runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$UID}"

      # Escape hatch: `touch $XDG_RUNTIME_DIR/xdph-manual-picker` to get the
      # normal dialog back while a game is running (share a browser to a friend
      # mid-session); `rm` it to go back to auto-selection.
      if [ -e "$runtime_dir/xdph-manual-picker" ]; then
        echo "manual picker requested, skipping game auto-selection" >&2
        fallback "$@"
      fi

      # No toplevel list means xdph cannot capture windows at all (no
      # hyprland-toplevel-export support), so window auto-selection is moot.
      if [ -z "''${XDPH_WINDOW_SHARING_LIST:-}" ]; then
        fallback "$@"
      fi

      clients=$("$hyprctl" -j clients 2>/dev/null || true)
      if [ -z "$clients" ]; then
        echo "hyprctl returned no clients, falling back to the interactive picker" >&2
        fallback "$@"
      fi

      # Fullscreen games win over windowed ones, then the most recently focused
      # window (focusHistoryID 0 is the focused window, which at share time is
      # usually Discord itself - hence the class filters rather than "whatever is
      # focused").
      game=$(printf '%s' "$clients" | jq -r \
        --argjson include ${lib.escapeShellArg (builtins.toJSON pickerCfg.gameClasses)} \
        --argjson exclude ${lib.escapeShellArg (builtins.toJSON pickerCfg.excludeClasses)} '
          [ .[]
            | select(.mapped)
            | (.class // "") as $class
            | select(any($include[]; . as $p | ($class | test($p; "i"))))
            | select(all($exclude[]; . as $p | ($class | test($p; "i") | not)))
          ]
          | sort_by([(if .fullscreen != 0 then 0 else 1 end), .focusHistoryID])
          | if length == 0 then empty else "\(.[0].address)\t\(.[0].class)" end
        ' || true)

      if [ -z "$game" ]; then
        echo "no game window found, falling back to the interactive picker" >&2
        fallback "$@"
      fi

      address=''${game%%$'\t'*}
      class=''${game#*$'\t'}

      # Match the game to a toplevel handle by address; fall back to matching the
      # class, in case toplevel-mapping is unavailable and the address field is 0.
      handle=$(printf '%s' "$XDPH_WINDOW_SHARING_LIST" | awk \
        -v want="$((address))" \
        -v class="$class" '
          BEGIN { RS = "\\[HA>\\]"; FS = "\\[HC>\\]|\\[HT>\\]|\\[HE>\\]" }
          NF < 4 { next }
          $4 == want { print $1; found = 1; exit }
          $2 == class && byClass == "" { byClass = $1 }
          END { if (!found && byClass != "") print byClass }
        ')

      if [ -z "$handle" ]; then
        echo "game window $class ($address) is not capturable, falling back to the interactive picker" >&2
        fallback "$@"
      fi

      echo "auto-selecting $class ($address) as toplevel handle $handle" >&2
      printf '[SELECTION]/window:%s\n' "$handle"
    '';
  };
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.desktop.hyprland.sharePicker = {
      enable = mkEnableOption "auto-selecting the running game as the screen share source";

      gameClasses = mkOption {
        type = types.listOf types.str;
        default = [
          "^steam_app_[0-9]+$"
          "^gamescope$"
          "^steam_proton$"
          "\\.exe$"
          "^Minecraft"
        ];
        description = ''
          Case-insensitive regexes matched against a window's class. The first
          match (fullscreen first, then most recently focused) is shared without
          any dialog. When nothing matches, the normal picker opens.
        '';
      };

      excludeClasses = mkOption {
        type = types.listOf types.str;
        default = [
          "^discord$"
          "^vesktop$"
          "^legcord$"
          "^steam$"
          "^steamwebhelper$"
        ];
        description = ''
          Case-insensitive regexes that veto a `gameClasses` match, for windows
          that look like games to the patterns above but are not (Windows apps
          run through WinApps, the Steam client itself, ...).
        '';
      };
    };
  };

  config = mkIf (cfg.enable && pickerCfg.enable) {
    home-manager.users.tiebe = {lib, ...}: {
      # xdph reads this file once, at startup.
      xdg.configFile."hypr/xdph.conf".text = ''
        screencopy {
            custom_picker_binary = ${lib.getExe picker}

            # Restore tokens are class-keyed and replay silently, which fights
            # the auto-selection above; keep them off.
            allow_token_by_default = false
        }
      '';

      # Without this, the new picker only takes effect after the next login.
      home.activation.reloadXdph = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -S "''${XDG_RUNTIME_DIR:-/run/user/$UID}/bus" ]; then
          $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user try-restart xdg-desktop-portal-hyprland.service || true
        fi
      '';
    };
  };
}
