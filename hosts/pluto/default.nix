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

  networking.hostName = "pluto";

  hardware.opengl = {
    # Mesa
    enable = true;
    # Vulkan
    driSupport = true;
  };
}