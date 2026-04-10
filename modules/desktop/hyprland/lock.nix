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
  lockCfg = config.tiebe.desktop.hyprland.lock;
in {
  options = {
    tiebe.desktop.hyprland.lock = {
      enable = mkEnableOption "Hyprlock (lock screen)";
    };
  };

  config = mkIf (cfg.enable && lockCfg.enable) {
    home-manager.users.tiebe = {
      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            disable_loading_bar = false;
            grace = 3;
            hide_cursor = true;
            no_fade_in = false;
          };

          background = [
            {
              path = "screenshot";
              blur_passes = 4;
              blur_size = 8;
              noise = 1.17e-2;
              contrast = 0.8916;
              brightness = 0.7;
              vibrancy = 0.1696;
              vibrancy_darkness = 0.0;
            }
          ];

          input-field = [
            {
              size = "300, 50";
              outline_thickness = 3;
              dots_size = 0.33;
              dots_spacing = 0.15;
              dots_center = true;
              dots_rounding = -1;
              outer_color = "rgb(cba6f7)"; # mauve
              inner_color = "rgb(1e1e2e)"; # base
              font_color = "rgb(cdd6f4)"; # text
              fade_on_empty = true;
              fade_timeout = 1000;
              placeholder_text = "<i>Password...</i>";
              hide_input = false;
              rounding = 14;
              check_color = "rgb(a6e3a1)"; # green
              fail_color = "rgb(f38ba8)"; # red
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
              fail_transition = 300;
              capslock_color = "rgb(fab387)"; # peach
              numlock_color = -1;
              bothlock_color = -1;
              invert_numlock = false;
              swap_font_color = false;
              position = "0, -20";
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            # Time
            {
              text = "$TIME";
              color = "rgb(cdd6f4)"; # text
              font_size = 90;
              font_family = "Montserrat Bold";
              position = "0, 150";
              halign = "center";
              valign = "center";
              shadow_passes = 3;
              shadow_size = 5;
            }
            # Date
            {
              text = "cmd[update:3600000] date +\"%A, %B %d\"";
              color = "rgb(bac2de)"; # subtext1
              font_size = 22;
              font_family = "Montserrat";
              position = "0, 70";
              halign = "center";
              valign = "center";
              shadow_passes = 3;
              shadow_size = 3;
            }
            # User greeting
            {
              text = "Hi, $USER";
              color = "rgb(cba6f7)"; # mauve
              font_size = 16;
              font_family = "Montserrat";
              position = "0, 30";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
  };
}
