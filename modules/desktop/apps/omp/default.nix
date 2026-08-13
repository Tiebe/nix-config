{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.omp;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.omp = {
      enable = mkEnableOption "Oh My Pi (omp) AI coding agent";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      inputs,
      pkgs,
      ...
    }: {
      imports = [inputs.omp.homeManagerModules.default];

      programs.omp = {
        enable = true;
        package = pkgs.callPackage ./package.nix {};
        settings = import ./config/settings.nix;
      };
    };
  };
}
