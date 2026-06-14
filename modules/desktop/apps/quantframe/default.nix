{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.quantframe;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.quantframe = {
      enable = mkEnableOption "Quantframe Warframe trading companion";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.quantframe];
  };
}
