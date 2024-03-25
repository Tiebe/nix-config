{ config, pkgs, osConfig, ... }:
{
  home.packages = with pkgs; [
    spotify-tui
  ];

  home.file."${config.home.homeDirectory}/.config/spotify-tui/client.yml".source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.spotifytui.path;
}