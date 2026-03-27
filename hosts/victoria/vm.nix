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
    ./modules-vm.nix
    # Note: hardware-configuration-vm.nix is NOT imported for the VM test
    # The NixOS VM module creates its own disk automatically
  ];

  # Platform settings (were in hardware-configuration-vm.nix)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Enable erase darlings for testing
  tiebe.system.boot.darlings.enable = true;

  # Enable evict darlings (two-tier home directory)
  tiebe.system.boot.evictDarlings.enable = true;

  services.fwupd.enable = lib.mkDefault false; # Disable in VM
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "victoria-test-vm";

  security.pam.services.login.fprintAuth = false;

  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  # VM-specific settings
  networking.firewall.enable = false;

  # Enable SSH for easier testing
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # Auto-login for testing convenience
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "tiebe";

  # Ensure home-manager applications appear in Plasma menu
  # by linking home-manager profile desktop files system-wide
  environment.pathsToLink = [
    "/share/applications"
    "/share/icons"
  ];

  # Make sure the session sources home-manager session variables
  environment.sessionVariables = {
    HM_SESSION_VARS = "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh";
  };

  # Configure second disk for persist (attached as /dev/vdb by test-vm.sh)
  fileSystems."/persist" = {
    device = "/dev/vdb";
    fsType = "btrfs";
    options = ["subvol=persist" "noatime"];
    neededForBoot = true;
  };

  system.stateVersion = "25.05";
}
