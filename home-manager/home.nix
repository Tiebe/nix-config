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
    gh
    kitty
    wofi
    discord
    hashcat
    bluetuith
    grim
    slurp
    warp-terminal
    sops
    gnupg
    wget
    jetbrains.idea-ultimate
    jetbrains.clion
  ];

  programs.home-manager.enable = true;
  programs.git.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}
