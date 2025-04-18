{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.wezterm;
in {
  options = {
    tiebe.desktop.apps.wezterm = {
      enable = mkEnableOption "Wezterm";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      programs.wezterm = {
        enable = true;
        enableZshIntegration = true;
        #        extraConfig = builtins.readFile ./wezterm.lua;
      };
    };
  };
}
