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

  /*
  Dark/light toggle script — switches between Mocha and Latte
  */
  toggle-theme = pkgs.writeShellScriptBin "toggle-catppuccin" ''
    current=$(${pkgs.plasma-workspace}/bin/plasma-apply-colorscheme --list-schemes 2>/dev/null | grep '^\*' | sed 's/^\* //')
    if echo "$current" | grep -qi "latte"; then
      ${pkgs.plasma-workspace}/bin/plasma-apply-colorscheme CatppuccinMochaMauve
    else
      ${pkgs.plasma-workspace}/bin/plasma-apply-colorscheme CatppuccinLatteMauve
    fi
  '';
in {
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    ./darlings.nix
  ];

  options = {
    tiebe.theme.catppuccin = {
      enable = mkEnableOption "Catppuccin theming";
    };
  };

  config = mkIf cfg.enable {
    /*
    NixOS-level catppuccin
    */
    catppuccin = {
      flavor = "mocha";
      accent = "mauve";
      sddm.enable = true;
    };

    environment.systemPackages = [toggle-theme];

    home-manager.users.tiebe = {inputs, ...}: {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      catppuccin = {
        flavor = "mocha";
        accent = "mauve";
        rofi.enable = true;
        waybar.enable = true;
        wlogout.enable = true;
        mako.enable = false;
        kvantum.enable = true;
        enable = true;
      };

      /*
      Kvantum as Qt style engine
      */
      qt = {
        enable = true;
        style.name = "kvantum";
      };

      home.pointerCursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
  };
}
