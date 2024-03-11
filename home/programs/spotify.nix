{ config, pkgs, osConfig, ... }:

let
  spotify_client_id = pkgs.runCommand "spotify_client_id" { input = osConfig.sops.secrets."spotify/client_id".path; } "cat $input > $out";
  spotify_client_secret = pkgs.runCommand "spotify_client_secret" { input = osConfig.sops.secrets."spotify/client_secret".path; } "cat $input > $out";
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