{inputs, ...}: {
  imports = [
    ./base/age.nix
    ./base/locale.nix
    ./base/nix.nix
    ./desktop/gnome
    ./desktop/plasma
    ./desktop/theme
    ./desktop/apps
    ./terminal
    ./system
  ];
}
