{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.fusion360;

  fusion360Package = pkgs.callPackage ./package.nix {
    installerSrc = inputs.fusion360-installer-src;
  };
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.fusion360 = {
      enable = mkEnableOption "Fusion 360";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [fusion360Package];

    # Register the adskidmgr:// URL scheme handler
    xdg.mime.defaultApplications = {
      "x-scheme-handler/adskidmgr" = "adskidmgr-opener.desktop";
    };

    environment.etc."xdg/applications/adskidmgr-opener.desktop".source =
      "${fusion360Package}/share/applications/adskidmgr-opener.desktop";
  };
}
