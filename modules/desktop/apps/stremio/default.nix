{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.stremio;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.stremio = {
      enable = mkEnableOption "Stremio media center";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      stremio-linux-shell
    ];
  };
}
