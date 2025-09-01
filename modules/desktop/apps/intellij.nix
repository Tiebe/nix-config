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
  cfg = config.tiebe.desktop.apps.intellij;
in
{
  options = {
    tiebe.desktop.apps.intellij = {
      enable = mkEnableOption "Enable IntelliJ IDEA";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.jetbrains.idea-ultimate
    ];
  };
}