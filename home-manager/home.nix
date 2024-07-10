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
    jetbrains-toolbox
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
    #busybox
  #  rquickshare
    verilator
    gnumake
    gcc
    verilog
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
