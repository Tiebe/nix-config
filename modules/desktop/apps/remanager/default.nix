{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.remanager;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.remanager = {
      enable = mkEnableOption "reManager (reMarkable tablet mod manager)";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [outputs.overlays.modifications];
    environment.systemPackages = [pkgs.remanager];
  };
}
