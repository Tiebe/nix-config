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
        "$mod" = "SUPER";

        bind = [
          # Application launchers
          "$mod SHIFT, Return, exec, rofi-launcher"
          "$mod, Return, exec, wezterm"
          "$mod, Q, killactive,"
          "$mod, F, fullscreen, 0"
          "$mod SHIFT, F, fullscreen, 1" # maximize
          "$mod, V, togglefloating,"
          "$mod, P, pseudo," # dwindle
          "$mod, S, layoutmsg, togglesplit" # dwindle

          # Lock / logout
          "$mod, L, exec, hyprlock"
          "$mod, M, exec, wlogout"

          # Screenshots
          ", Print, exec, screenshot-full"
          "$mod SHIFT, S, exec, screenshot-area"

          # Clipboard history
          "$mod SHIFT, V, exec, clipboard-history"

          # Notification center
          "$mod, N, exec, swaync-client -t -sw"

          # Focus movement
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"

          # Window movement
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"

          # Workspace switching
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move to workspace
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Special workspace (scratchpad)
          "$mod, grave, togglespecialworkspace, magic"
          "$mod SHIFT, grave, movetoworkspace, special:magic"

          # Scroll through workspaces
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          # Tab through recent workspaces
          "$mod, Tab, workspace, previous"
        ];

        # Repeat binds (hold to repeat)
        binde = [
          # Resize
          "$mod CTRL, left, resizeactive, -20 0"
          "$mod CTRL, right, resizeactive, 20 0"
          "$mod CTRL, up, resizeactive, 0 -20"
          "$mod CTRL, down, resizeactive, 0 20"
          "$mod CTRL, H, resizeactive, -20 0"
          "$mod CTRL, L, resizeactive, 20 0"
          "$mod CTRL, K, resizeactive, 0 -20"
          "$mod CTRL, J, resizeactive, 0 20"
        ];

        # Mouse binds
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Locked binds (work even when locked)
        bindl = [
          # Media controls
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
          ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"
        ];

        # Locked + repeat binds
        bindle = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
        ];
      };
    };
  };
}
