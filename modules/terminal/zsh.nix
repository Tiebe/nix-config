{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.terminal.zsh;
in {
  options = {
    tiebe.terminal.zsh = {
      enable = mkEnableOption "the zsh shell, with plugins";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      programs.zsh = {
        enable = true;
        enableCompletion = false;

        shellAliases = {
          "fullupdate" = "sudo ls /dev/null > /dev/null 2>&1 && cd /etc/nixos && git pull && nix flake update && nix fmt && sudo nixos-rebuild switch --flake . |& nom && cd -";
          "update" = "sudo ls /dev/null > /dev/null 2>&1 && cd /etc/nixos && git pull && nix fmt && sudo nixos-rebuild switch --flake . |& nom && cd -";
          "capture-plasma" = "nix run github:nix-community/plasma-manager > /etc/nixos/modules/desktop/plasma/config.nix && echo 'Captured Plasma config.'";
          "o" = "xdg-open";
          "db" = "distrobox";
          "dbe" = "distrobox enter";
          "cat" = "bat";
          "code" = "codium";
        };

        antidote = {
          enable = true;
          plugins = [
            "zsh-users/zsh-autosuggestions"
            "zsh-users/zsh-syntax-highlighting"
            "zsh-users/zsh-completions"
            "zsh-users/zsh-history-substring-search"
            "chrissicool/zsh-256color"
            "djui/alias-tips"
            #"yuhonas/zsh-ansimotd"
            #"marlonrichert/zsh-autocomplete"
            "Tarrasch/zsh-bd"
            # "MikeDacre/careful_rm"
            "bartboy011/cd-reminder"
            "ChrisPenner/copy-pasta"
            "mrjohannchang/zsh-interactive-cd"
            "mfaerevaag/wd"
            "ptavares/zsh-direnv"
            "birdhackor/zsh-eza-ls-plugin"
            "aubreypwd/zsh-plugin-fd"
            "atuinsh/atuin"
            "mfaerevaag/wd"
          ];
        };

        initContent = lib.mkMerge [
          (lib.mkBefore ''
            export WEZTERM_SHELL_SKIP_ALL=1
          '')

          ''
            bindkey '^[[1;5D' backward-word
            bindkey '^[[1;5C' forward-word
          ''
        ];
      };

      home.file.".rm_recycle_home".text = "";

      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          format = "$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$character";
        };
      };

      programs.atuin = {
        enable = true;
        flags = ["--disable-up-arrow"];
        settings = {
          key_path = config.age.secrets.atuin.path;
          daemon.enabled = true;
        };
      };
    };
    systemd.user.services.atuind = {
      enable = true;

      environment = {
        ATUIN_LOG = "info";
      };
      serviceConfig = {
        ExecStart = "${pkgs.atuin}/bin/atuin daemon";
      };
      after = ["network.target"];
      wantedBy = ["default.target"];
    };
  };
}
