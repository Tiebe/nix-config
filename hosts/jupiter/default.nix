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

  networking.hostName = "jupiter";

  hardware.opengl = {
    # Mesa
    enable = true;
    # Vulkan
    driSupport = true;
  };
}