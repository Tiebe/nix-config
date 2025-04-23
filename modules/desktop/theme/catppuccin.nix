{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.theme.catppuccin;
in {
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  options = {
    tiebe.theme.catppuccin = {
      enable = mkEnableOption "Catppuccin theming";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {inputs, ...}: {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      catppuccin = {
        flavor = "mocha";
        rofi.enable = true;
        waybar.enable = true;
        wlogout.enable = true;
        enable = true;
      };

      home.pointerCursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
  };
}
