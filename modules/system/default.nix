{inputs, ...}: {
  imports = [
    ./boot/systemdboot.nix
    ./boot/plymouth.nix
    ./networking/bluetooth.nix
    ./networking/network.nix
    ./networking/tailscale.nix
    ./networking/wifi.nix
    ./sound.nix
    ./users/tiebe
    ./users/tiebe/email.nix
    ./ddc.nix
    ./users/evict-your-darlings.nix
    ./boot/erase-your-darlings
  ];
}
