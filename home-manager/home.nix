{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../home
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "tiebe";
    homeDirectory = "/home/tiebe";
  };

  home.packages = with pkgs; [
    vscode
    kitty
    wofi
    vesktop
    hashcat
    bluetuith
    grim
    slurp
    sops
    gnupg
    wget
    jetbrains.idea-ultimate
    jetbrains.clion
    parsec-bin
    onlyoffice-bin
    prismlauncher-qt5
    spotify
    wine
    bottles
    vlc
    desktop-file-utils
    vital
    qpwgraph
    distrobox
    chntpw
    spotify
    tidal-hifi
  ];

  programs.home-manager.enable = true;
  programs.git = {
      enable = true;
      userName = "Tiebe Groosman";
      userEmail = "tiebe.groosman@gmail.com";
  };

  programs.gh.enable = true;

  systemd.user.startServices = "sd-switch";

  services.arrpc.enable = true;

  home.stateVersion = "23.11";
}
