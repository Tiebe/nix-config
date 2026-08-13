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
  idleCfg = config.tiebe.desktop.hyprland.idle;
in {
  options = {
    tiebe.desktop.hyprland.idle = {
      enable = mkEnableOption "Hypridle (idle daemon)";
    };
  };

  config = mkIf (cfg.enable && idleCfg.enable) {
    home-manager.users.tiebe = {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
          };

          listener = [
            # Turn off displays after 15 minutes of idle (desktop-first, no auto-lock)
            {
              timeout = 900;
              on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
              on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
            }
          ];
        };
      };
    };
  };
}
