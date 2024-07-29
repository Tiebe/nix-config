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
    kernelModules = ["amdgpu"];
    verbose = false;
  };

  custom.root = "/etc/nixos";

  services.xserver.videoDrivers = ["amdgpu"];

  networking.hostName = "jupiter";

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  hardware.graphics.enable = true;

  networking.interfaces.enp7s0.wakeOnLan.enable = true;
}
