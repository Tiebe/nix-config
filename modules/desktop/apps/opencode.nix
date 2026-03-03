{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.opencode;
in
{
  options = {
    tiebe.desktop.apps.opencode = {
      enable = mkEnableOption "OpenCode";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (
        writeShellApplication { 
          name = "opencode";
          text = '' exec ${nodejs}/bin/npx opencode-ai@latest "$@" ''; 
        }
      )
    ];
  };
}