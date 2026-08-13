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
in {
  options = {
    tiebe.desktop.hyprland.binds = {
      enable = mkEnableOption "Hyprland keybindings";
    };
  };

  config = mkIf (cfg.enable && bindsCfg.enable) {
    home-manager.users.tiebe = {
      home.packages = [
        screenshotArea
        screenshotFull
        clipboardHistory
      ];

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
          (bindFlags "XF86MonBrightnessUp" (mkExec "${pkgs.brightnessctl}/bin/brightnessctl set 5%+") {
            locked = true;
            repeating = true;
          })
          (bindFlags "XF86MonBrightnessDown" (mkExec "${pkgs.brightnessctl}/bin/brightnessctl set 5%-") {
            locked = true;
            repeating = true;
          })
        ];
      };
    };
  };
}
