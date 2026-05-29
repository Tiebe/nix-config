{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.bambu-studio;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.bambu-studio = {
      enable = mkEnableOption "bambu-studio";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.bambu-studio];
  };
}
