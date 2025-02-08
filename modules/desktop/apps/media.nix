{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.media;
in {
  options = {
    tiebe.desktop.apps.media = {
      enable = mkEnableOption "different media apps, like Spotify and VLC";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spotify
      vlc
    ];
  };
}
