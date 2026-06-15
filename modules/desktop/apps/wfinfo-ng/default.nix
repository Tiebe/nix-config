{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.wfinfo-ng;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.wfinfo-ng = {
      enable = mkEnableOption "WFinfo-ng Warframe relic reward analyzer";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [(pkgs.callPackage ./package.nix {})];
  };
}
