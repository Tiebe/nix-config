{ config, pkgs, osConfig, ... }:

let
  spotify_client_id = ""; # pkgs.runCommand "spotify_client_id" { input = /run/secrets/spotify/client_id; } "cat $input > $out";
  spotify_client_secret = ""; #  pkgs.runCommand "spotify_client_secret" { input = /run/secrets/spotify/client_secret; } "cat $input > $out";
 in {
  home.packages = with pkgs; [
    spotify-tui
  ];

  home.file."${config.home.homeDirectory}/.config/spotify-tui/client.yml".source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.spotifytui.path;
}