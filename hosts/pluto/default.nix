{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  boot.initrd = {
    kernelModules = ["i915"];
    verbose = false;
  };

  services.xserver.videoDrivers = ["displaylink" "modesetting"];

  custom.root = "/etc/nixos";

  networking.hostName = "pluto";

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa.drivers
      vpl-gpu-rt # or intel-media-sdk for QSV
    ];
  };
}
