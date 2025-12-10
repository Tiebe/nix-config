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
in {
  options = {
    tiebe.desktop.plasma = {
      enable = mkEnableOption "the KDE Plasma desktop";
    };
  };

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      # wayland.enable = true;
    };

    services.xserver.enable = true;

    services.displayManager.defaultSession = "plasmax11";
    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
    ];

    home-manager.users.tiebe = {
      imports = [./config.nix];
    };
  };
}
