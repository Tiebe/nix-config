{inputs, ...}: {
  imports = [
    ./boot/systemdboot
    ./boot/plymouth
    ./networking/bluetooth
    ./networking/network
    ./networking/tailscale
    ./networking/wifi
    ./sound
    ./users/tiebe
    ./users/tiebe/email
    ./users/robbin
    ./ddc
    ./boot/darlings
    ./boot/evict-darlings
    ./darlings.nix
  ];
}
