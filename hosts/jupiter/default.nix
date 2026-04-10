{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  lowpower = pkgs.writeShellScriptBin "lowpower" ''
    #!/usr/bin/env bash
    kscreen-doctor \
      output.DisplayPort-0.mode.89 \
      output.DisplayPort-2.mode.138
  '';

  highpower = pkgs.writeShellScriptBin "highpower" ''
    #!/usr/bin/env bash
    kscreen-doctor \
      output.DisplayPort-0.mode.90 \
      output.DisplayPort-2.mode.139
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ./modules.nix
  ];

  boot.kernelPackages =
    inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;

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

  environment.systemPackages = with pkgs; [
    lowpower
    highpower
  ];

  services.esphome.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
