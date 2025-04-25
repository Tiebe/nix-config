{inputs, ...}: {
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./config
    ./greetd.nix
    ./waybar
    ./programs/swaync.nix
    ./programs/rofi.nix
  ];
}
