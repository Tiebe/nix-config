{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./firefox.nix
    ./plasma
    ./wezterm
    ./spotify-player
    ./neovim
    #./discord
  ];
}
