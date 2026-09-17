{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.music-assistant;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.music-assistant = {
      enable = mkEnableOption "Music Assistant Companion, the official desktop client for a Music Assistant server";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      music-assistant-desktop
    ];
  };
}
