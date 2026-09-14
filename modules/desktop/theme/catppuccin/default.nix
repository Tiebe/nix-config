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
    current=$(${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-colorscheme --list-schemes 2>/dev/null | grep '^\*' | sed 's/^\* //')
    if echo "$current" | grep -qi "latte"; then
      ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-colorscheme CatppuccinMochaMauve
    else
      ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-colorscheme CatppuccinLatteMauve
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
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      accent = "mauve";
      sddm.enable = true;
    };

    environment.systemPackages = [toggle-theme];

    home-manager.users.tiebe = {inputs, ...}: {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      /*
      KDE color schemes + window decorations (both flavors for toggle)
      */
      home.packages = [
        (pkgs.catppuccin-kde.override {
          flavour = ["mocha" "latte"];
          accents = ["mauve"];
          winDecStyles = ["modern"];
        })
      ];

      catppuccin = {
        enable = true;
        autoEnable = true;
        flavor = "mocha";
        accent = "mauve";
        rofi.enable = true;
        waybar.enable = true;
        wlogout.enable = true;
        mako.enable = false;
        kvantum.enable = true;
        hyprland.enable = false;
      };

      /*
      Kvantum as Qt style engine
      */
      qt = {
        enable = true;
        style.name = "kvantum";
      };

      /*
      catppuccin.gtk.icon sets gtk.iconTheme, but home-manager only installs the
      icon theme and writes gtk-icon-theme-name when its gtk module is enabled.
      Without it nothing on the system ships an app icon theme, so icon lookups
      (DMS's launcher, GTK apps) fall back to hicolor and come up empty.
      */
      gtk.enable = true;

      home.pointerCursor = {
        enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
  };
}
