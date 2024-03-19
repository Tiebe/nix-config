{
  pkgs,
  lib,
  inputs,
  theme,
  ...
}: 

let
  spotify_email = ""; # pkgs.runCommand "spotify_email" { input = /run/secrets-for-users/spotify/email; } "cat $input > $out";
  spotify_password = ""; # pkgs.runCommand "spotify_password" { input = /run/secrets-for-users/spotify/password; } "cat $input > $out";
 in
{
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
#        username = (builtins.readFile spotify_email);
#        password = (builtins.readFile spotify_password);
      };
    };
  };
}
