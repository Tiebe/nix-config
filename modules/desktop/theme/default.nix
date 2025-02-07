{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.theme;
in {
  imports = [inputs.stylix.nixosModules.stylix];

  options = {
    tiebe.desktop.theme = {
      enable = mkEnableOption "theming options using stylix";
    };
  };

  config = mkIf cfg.enable {
    stylix.enable = true;

    stylix.image = ./wallpaper.jpg;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-savanna.yaml";
    stylix.fonts.serif = config.stylix.fonts.sansSerif;

    stylix.fonts.sizes.applications = 10;
    stylix.cursor.size = 10;

    stylix.fonts.sizes.desktop = 10;
    stylix.fonts.sizes.popups = 10;
    stylix.fonts.sizes.terminal = 10;

    #stylix.polarity = "dark";
  };
}
