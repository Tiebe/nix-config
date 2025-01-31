{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./zsh.nix
    ./git.nix
    ./firefox.nix
    ./plasma
    ./wezterm
    ./spotify-player
    ./neovim
    #./discord
    ./winapps
  ];
}
