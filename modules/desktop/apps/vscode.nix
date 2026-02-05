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
    environment.systemPackages = with pkgs; [nil];

    home-manager.users.tiebe = {
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
            #ms-python.python
            ms-python.pylint
            # ms-python.vscode-pylance
            ms-azuretools.vscode-docker
            jock.svg
            jnoortheen.nix-ide
          ];

          userSettings = {
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nil";
            "[nix]"."editor.tabSize" = 2;
            "files.autoSave" = "on";
          };
        };
      };
    };
  };
}
