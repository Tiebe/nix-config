{
  pkgs,
  lib,
  inputs,
  theme,
  ...
}: 
{
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "tiebe.groosman@gmail.com";
        password_cmd = "bash -c 'cat /run/secrets/spotify/password'";
        device_name = "PC";
        device_type = "computer";
      };
    };
  };
}
