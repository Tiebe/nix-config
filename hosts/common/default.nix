{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  specialArgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./age.nix
    ./system
  ];

  options.custom = {
    root = lib.mkOption {
      type = with lib.types; uniq str;
      example = "/etc/nixos";
      description = ''
        Root of nix flake.
      '';
    };
  };

  config = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
    ];

    programs.adb.enable = true;
    programs.java.enable = true;

    environment.systemPackages = with pkgs; [
      jdk21
      gtkmm3
      (pkgs.discord.override {
        withVencord = true;
        withOpenASAR = true;
      })
      vencord
    ];

    virtualisation.docker.enable = true;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
  };
}
