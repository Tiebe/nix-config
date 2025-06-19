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
  ];

  services.fwupd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "victoria";

  system.stateVersion = "25.05";
}
