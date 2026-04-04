{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.localsend;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.localsend = {
      enable = mkEnableOption "localsend";
    };
  };

  config = mkIf cfg.enable {
    programs.localsend.enable = true;
  };
}
