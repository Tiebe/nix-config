{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    tiebe.installer = {
      enable = mkEnableOption "NixOS installer ISO with erase-your-darlings support";
    };
  };

  config = mkIf config.tiebe.installer.enable {
    # ISO-specific settings
    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;

    # Enable flakes in the installer
    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Include useful tools
    environment.systemPackages = with pkgs; [
      git
      vim
      neovim
      disko
      gum
      util-linux
      parted
      btrfs-progs
    ];

    # Installer user
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
      initialPassword = "nixos";
    };

    # Auto-login for convenience
    services.getty.autologinUser = "nixos";

    # Enable SSH for remote installation
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
      settings.PasswordAuthentication = true;
    };

    # Network
    networking = {
      networkmanager.enable = true;
      wireless.enable = lib.mkForce false;
    };

    # Disable firewall for installer
    networking.firewall.enable = false;

    # Boot settings for ISO
    boot.loader.grub.enable = false;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
