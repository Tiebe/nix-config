{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.legcord;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.legcord = {
      enable = mkEnableOption "Legcord";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      legcord
    ];
  };
}
