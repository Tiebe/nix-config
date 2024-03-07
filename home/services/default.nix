{
  pkgs,
  lib,
  inputs,
  theme,
  ...
}: {
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "";
        password = "";
      };
    };
  };
}