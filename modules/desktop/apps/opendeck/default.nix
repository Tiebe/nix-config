{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.opendeck;
  opendeck = pkgs.callPackage ./package.nix {};
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.opendeck = {
      enable = mkEnableOption "OpenDeck stream controller software";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [opendeck];

    # 40-streamdeck.rules, shipped by upstream, tags Elgato devices with
    # uaccess so the logged-in user can talk to them over hidraw.
    services.udev.packages = [opendeck];
  };
}
