{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.minecraft;
in {
  options = {
    tiebe.desktop.apps.minecraft = {
      enable = mkEnableOption "PrismLauncher";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      prismlauncher
    ];
  };
}
