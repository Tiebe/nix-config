{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ./modules.nix
    ./hardware-configuration.nix
  ];

  services.fwupd.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "victoria";

  # kernel patch until https://gitlab.gnome.org/GNOME/gdm/-/issues/974 is resolved
  # boot.kernelPatches = [
  #   {
  #     name = "gdm-amd-gpu-fix";
  #     patch = ./boot_vga.patch;
  #   }
  # ];

  networking.firewall.enable = true;

  system.stateVersion = "25.05";
}
