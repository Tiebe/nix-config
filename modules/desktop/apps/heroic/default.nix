{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.heroic;
in {
  imports = [./darlings.nix];

  options.tiebe.desktop.apps.heroic = {
    enable = mkEnableOption "Heroic Games Launcher";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.heroic];
  };
}
