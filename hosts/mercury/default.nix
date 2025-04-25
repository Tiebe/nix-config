{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./modules.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "tiebe";

    usbip = {
      enable = true;
      # Replace this with the BUSID for your Yubikey
      autoAttach = ["7-1"];
    };
  };
  environment.systemPackages = [
    pkgs.linuxPackages.usbip
    pkgs.yubikey-manager
    pkgs.libfido2
  ];

  services.pcscd.enable = true;
  services.udev = {
    enable = true;
    packages = [pkgs.yubikey-personalization];
    extraRules = ''
      SUBSYSTEM=="usb", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0666"
    '';
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "mercury";

  system.stateVersion = "24.05";
}
