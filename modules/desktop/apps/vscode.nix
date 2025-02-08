{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.vscode;
in {
  options = {
    tiebe.desktop.apps.vscode = {
      enable = mkEnableOption "VSCode";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      programs.vscode = {
        enable = true;
      };
    };
  };
}
