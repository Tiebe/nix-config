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
    kernelModules = ["i915"];
    verbose = false;
  };

  services.xserver.videoDrivers = ["displaylink" "modesetting"];

  networking.hostName = "pluto";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa.drivers
      vpl-gpu-rt # or intel-media-sdk for QSV
      vaapiIntel
      intel-media-driver
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
