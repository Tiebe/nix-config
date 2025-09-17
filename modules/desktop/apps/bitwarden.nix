{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.bitwarden;
in {
  options = {
    tiebe.desktop.apps.bitwarden = {
      enable = mkEnableOption "Bitwarden desktop";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.bitwarden-desktop];
  };
}
