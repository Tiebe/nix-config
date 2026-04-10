{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.opendeck;

  opendeckSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/afe52365430b38a05bae641b8f7ae2a4a6567595.tar.gz";
    sha256 = "sha256:0if4z1yhrgi9yzhmk951vlpvw33szx20g0ncndza4myybgmbn88k";
  };

  opendeckPkgs = import opendeckSrc {};
in {
  options = {
    tiebe.desktop.apps.opendeck = {
      enable = mkEnableOption "opendeck";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        opendeck = opendeckPkgs.opendeck;
      })
    ];

    environment.systemPackages = with pkgs; [
      opendeck
    ];
  };
}
