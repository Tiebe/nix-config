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

  bitfocus-companion-original = import ./package.nix { inherit (pkgs) stdenv lib fetchFromGitHub nodejs git python3 udev yarn-berry_4 libusb1 dart-sass electron_36 makeWrapper; };

  bitfocus-companion = bitfocus-companion-original.overrideAttrs (finalAttrs: previousAttrs: {
    patches = [ ./import.patch ];
  });
in
{
  options = {
    tiebe.services.bitfocus-companion = {
      enable = mkEnableOption "Bitfocus Companion";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ bitfocus-companion ];

    systemd.user.services.bitfocus-companion = {
      enable = true;
      wantedBy = [ "default.target" ];
      description = "Starts Bitfocus Companion";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${bitfocus-companion}/bin/bitfocus-companion --import-from-file ${ ./export.companionconfig }
        '';
      };
    };
  };
}