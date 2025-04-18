{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.parsec;
  parsec-custom = pkgs.callPackage ./parsec-wrapper.nix {};
in {
  options = {
    tiebe.desktop.apps.parsec = {
      enable = mkEnableOption "Parsec";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      parsec-custom.wrapper
      parsec-custom.desktop
    ];
  };
}
