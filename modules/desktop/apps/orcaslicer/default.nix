{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.orcaslicer;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.orcaslicer = {
      enable = mkEnableOption "orcaslicer";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.orca-slicer];
  };
}
