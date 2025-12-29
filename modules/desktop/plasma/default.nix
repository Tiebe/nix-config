{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.plasma;
  darlings = config.tiebe.system.boot.darlings;
in {
  options = {
    tiebe.desktop.plasma = {
      enable = mkEnableOption "the KDE Plasma desktop";
    };
  };

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
    ];

    fonts.packages = with pkgs; [
      inter
      jetbrains-mono
    ];

    environment.systemPackages = with pkgs; [
      papirus-icon-theme
      libsForQt5.qtstyleplugin-kvantum
      kdePackages.qtstyleplugin-kvantum
    ];

    home-manager.users.tiebe = {
      imports = [./config.nix];
    };
  };

  imports = [./darlings.nix];
}
