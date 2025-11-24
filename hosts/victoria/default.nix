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

  security.pam.services.login.fprintAuth = false;

  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  hardware.rtl-sdr.enable = true;
  users.users.tiebe.extraGroups = [ "plugdev" ];

  networking.firewall.enable = true;

  system.stateVersion = "25.05";
}
