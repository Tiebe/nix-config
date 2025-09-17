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

  jdkWithFX = pkgs.openjdk.override {
    enableJavaFX = true; # for JavaFX
  };
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
      pkgs.javaPackages.openjfx21
    ];

    programs.java = {
      enable = true;
      package = jdkWithFX;
    };
  };
}