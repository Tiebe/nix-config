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
    ./modules.nix
  ];

  boot.initrd = {
    kernelModules = ["amdgpu"];
    verbose = false;
  };

  services.xserver.videoDrivers = ["amdgpu" "modesetting"];

  networking.hostName = "jupiter";
  networking.hostId = "4ca1d14d";

  networking.firewall.enable = false;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # Replaced 'driSupport32Bit'
  networking.interfaces.enp7s0.wakeOnLan.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  systemd.tmpfiles.rules = ["L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"];
  hardware.graphics = {
    extraPackages = with pkgs; [
      libva
      libva-utils
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
