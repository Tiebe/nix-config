{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      "update" = "sudo ls /dev/null > /dev/null 2>&1 && nix flake update && nix fmt && sudo nixos-rebuild switch --flake . |& nom";
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
}
