{inputs, ...}: {
  imports = [
    ./boot/systemdboot
    ./boot/plymouth
    ./networking/bluetooth
    ./networking/network
    ./networking/tailscale
    ./networking/wifi
    ./sound
    ./sound/deep-filter
    ./users/tiebe
    ./users/tiebe/email
    ./users/robbin
    ./ddc
    ./boot/darlings
    ./boot/evict-darlings
    ./darlings.nix
  ];
}
