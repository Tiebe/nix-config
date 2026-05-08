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
  cfg = config.tiebe.desktop.apps.claude-code;
in
{
  options = {
    tiebe.desktop.apps.claude-code = {
      enable = mkEnableOption "Claude Code";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ];
    environment.systemPackages = [ pkgs.claude-desktop ];
  };
}