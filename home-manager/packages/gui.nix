{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    vesktop
    parsec-bin
    onlyoffice-bin
    spotify
    vlc
    kitty
  ];
}
