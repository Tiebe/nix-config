{ config, pkgs, ... }:

let
  spotify_client_id = pkgs.runCommand "spotify_client_id" { input = /run/secrets/spotify/client_id; } "cat $input > $out";
  spotify_client_secret = pkgs.runCommand "spotify_client_secret" { input = /run/secrets/spotify/client_secret; } "cat $input > $out";
 in {
  home.packages = with pkgs; [
    spotify-tui
  ];

  home.file."${config.home.homeDirectory}/.config/spotify-tui/client.yml".text = ''
---
client_id: ${(builtins.readFile spotify_client_id)}
client_secret: ${(builtins.readFile spotify_client_secret)}
device_id: ~
port: 8888
  '';
}