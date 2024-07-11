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
    vesktop
    sops
    gnupg
    wget
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains-toolbox
    parsec-bin
    onlyoffice-bin
    spotify
    vlc
    desktop-file-utils
    spotify
    shellify
  ];

  programs.home-manager.enable = true;
  programs.git = {
      enable = true;
      userName = "Tiebe Groosman";
      userEmail = "tiebe.groosman@gmail.com";
      extraConfig = {
        "url \"ssh://git@github.com/\"" = { insteadOf = https://github.com/; };
      };
  };

  programs.gh.enable = true;

  systemd.user.startServices = "sd-switch";

  services.arrpc.enable = true;

  home.stateVersion = "23.11";
}
