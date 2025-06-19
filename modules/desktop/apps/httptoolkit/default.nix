{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.httptoolkit;
in {
  options = {
    tiebe.desktop.apps.httptoolkit = {
      enable = mkEnableOption "HTTP Toolkit";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [httptoolkit httptoolkit-server];
  };
}
