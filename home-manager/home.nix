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
    direnv
    fzf
  ];

  services.lorri.enable = true;

  programs.home-manager.enable = true;
  programs.git = {
      enable = true;
      userName = "Tiebe Groosman";
      userEmail = "tiebe.groosman@gmail.com";
      extraConfig = {
        "url \"ssh://git@github.com/\"" = { insteadOf = https://github.com/; };
      };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      update = "sudo nixos-rebuild switch --flake";
      compose = "sudo docker compose";
      wolpc = "wakeonlan D8:5E:D3:A8:B1:0";
      capture-config = "nix run github:pjones/plasma-manager > ~/nix-config/home-manager/plasma.nix";
      reboot-to-windows = "sudo efibootmgr -n 0000";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "zsh-interactive-cd"
        "python"
        "git-auto-fetch"
        "wd"
        "direnv"
      ];
      #custom = "/home/horseman/nix-config/pkgs/zsh/";
      theme = "jonathan";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$character";
    };
  };

  programs.gh.enable = true;

  systemd.user.startServices = "sd-switch";

  services.arrpc.enable = true;

  home.stateVersion = "23.11";
}
