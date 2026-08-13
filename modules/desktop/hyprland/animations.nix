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
  animCfg = config.tiebe.desktop.hyprland.animations;
in {
  options = {
    tiebe.desktop.hyprland.animations = {
      enable = mkEnableOption "Hyprland animations";
    };
  };

  config = mkIf (cfg.enable && animCfg.enable) {
    home-manager.users.tiebe = {
      wayland.windowManager.hyprland.settings = {
        config.animations.enabled = true;

        # Snappy bezier curves
        curve = [
          {
            _args = [
              "snappy"
              {
                type = "bezier";
                points = [
                  [0.05 0.9]
                  [0.1 1.0]
                ];
              }
            ];
          }
          {
            _args = [
              "snappyFade"
              {
                type = "bezier";
                points = [
                  [0.2 0.8]
                  [0.2 1.0]
                ];
              }
            ];
          }
          {
            _args = [
              "snappyMove"
              {
                type = "bezier";
                points = [
                  [0.05 0.7]
                  [0.1 1.0]
                ];
              }
            ];
          }
          {
            _args = [
              "overshot"
              {
                type = "bezier";
                points = [
                  [0.05 0.9]
                  [0.1 1.05]
                ];
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 3;
            bezier = "snappy";
            style = "popin 80%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 3;
            bezier = "snappyFade";
            style = "popin 80%";
          }
          {
            leaf = "windowsMove";
            enabled = true;
            speed = 2;
            bezier = "snappyMove";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 3;
            bezier = "snappyFade";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 3;
            bezier = "snappy";
            style = "slide";
          }
          {
            leaf = "specialWorkspace";
            enabled = true;
            speed = 3;
            bezier = "snappy";
            style = "slidevert";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 5;
            bezier = "default";
          }
          {
            leaf = "borderangle";
            enabled = true;
            speed = 5;
            bezier = "default";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 2;
            bezier = "snappyFade";
            style = "fade";
          }
        ];
      };
    };
  };
}
