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

  custom.root = "/etc/nixos";

  services.xserver.videoDrivers = [ "amdgpu" "displaylink" "modesetting" ];

  networking.hostName = "jupiter";

  hardware.graphics.enable = true;
  networking.interfaces.enp7s0.wakeOnLan.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
