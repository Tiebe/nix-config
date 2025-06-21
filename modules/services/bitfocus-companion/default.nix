{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.bitfocus-companion;

  bitfocus-companion = import ./package.nix { inherit (pkgs) stdenv lib fetchFromGitHub nodejs git python3 udev yarn-berry_4 libusb1 dart-sass electron_36 makeWrapper; };
in
{
  options = {
    tiebe.services.bitfocus-companion = {
      enable = mkEnableOption "Bitfocus Companion";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ bitfocus-companion ];
  };
}