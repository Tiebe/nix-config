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
  evictCfg = config.tiebe.system.boot.evictDarlings;

  # Helper to fetch zsh plugins from GitHub
  zshPlugin = {
    owner,
    repo,
    rev,
    sha256,
  }:
    pkgs.stdenvNoCC.mkDerivation {
      name = "zsh-${repo}";
      src = pkgs.fetchFromGitHub {
        inherit owner repo rev sha256;
      };
      # Don't run build phase (tests) - just install the plugin files
      dontBuild = true;
      installPhase = ''
        mkdir -p $out/share/zsh/site-functions
        cp -r . $out/share/zsh/site-functions/${repo}
      '';
    };

  # Define custom plugins with corrected commit SHAs
  zsh-256color = zshPlugin {
    owner = "chrissicool";
    repo = "zsh-256color";
    rev = "559fee48bb74b75cec8b9887f8f3e046f01d5d8f";
    sha256 = "sha256-P/pbpDJmsMSZkNi5GjVTDy7R+OxaIVZhb/bEnYQlaLo=";
  };

  alias-tips = zshPlugin {
    owner = "djui";
    repo = "alias-tips";
    rev = "41cb143ccc3b8cc444bf20257276cb43275f65c4";
    sha256 = "sha256-ZFWrwcwwwSYP5d8k7Lr/hL3WKAZmgn51Q9hYL3bq9vE=";
  };

  zsh-bd = zshPlugin {
    owner = "Tarrasch";
    repo = "zsh-bd";
    rev = "646f06d9b6a840926a671fdc2da196d4eecfc305";
    sha256 = "sha256-JAC9u7IzkW0b7J43w4c+yLuPGdvMtxBlobrQwlyvVcM=";
  };

  cd-reminder = zshPlugin {
    owner = "bartboy011";
    repo = "cd-reminder";
    rev = "89e2d0caa502c714e5a7ba79e67d682151776ae2";
    sha256 = "sha256-YK1qpBW1UUNy1PnJTS6fvXlPDmRuVkgFsFYNyKSxEv4=";
  };

  copy-pasta = zshPlugin {
    owner = "ChrisPenner";
    repo = "copy-pasta";
    rev = "37218e948d2bd5b86685ee5518d1e6ee9944301e";
    sha256 = "sha256-AeoehSmi1KFyYWBHiWECu9qd7C9B/K0yIQe0UyI+3R0=";
  };

  zsh-interactive-cd = zshPlugin {
    owner = "mrjohannchang";
    repo = "zsh-interactive-cd";
    rev = "e7d4802aa526ec069dafec6709549f4344ce9d4a";
    sha256 = "sha256-j23Ew18o7i/7dLlrTu0/54+6mbY8srsptfrDP/9BI/Q=";
  };

  wd = zshPlugin {
    owner = "mfaerevaag";
    repo = "wd";
    rev = "7f87d4caa7d4073da4ba3e26c2cbcd26fe53a83b";
    sha256 = "sha256-Q3CE6+jxan0nczF5tIvmYKHBfR08eqd86Zogieh8YVU=";
  };

  zsh-direnv = zshPlugin {
    owner = "ptavares";
    repo = "zsh-direnv";
    rev = "da53dfcd57af83de8d052b74661c7d06c4dff723";
    sha256 = "sha256-V/x424mUyzJeA/t6QVQ3eS51S8zlk3vaestKybJOSIo=";
  };

  zsh-eza-ls-plugin = zshPlugin {
    owner = "birdhackor";
    repo = "zsh-eza-ls-plugin";
    rev = "e3b2394a5fa6b9d4689ac3c8d946fbbdaacb302d";
    sha256 = "sha256-+QCEejmEtMujBelMOZUjiHL4njT3YHs9fkIgYrL2Yxc=";
  };

  zsh-plugin-fd = zshPlugin {
    owner = "aubreypwd";
    repo = "zsh-plugin-fd";
    rev = "ac092b930fa0ff29d4384c8ff9ef30896bf024b3";
    sha256 = "sha256-H9g3ZLm2gaRaFNfQW0SGzWS3SIulbDkYgQokEaPuDC4=";
  };
in {
  imports = [./darlings.nix];

  options = {
    tiebe.terminal.zsh = {
      enable = mkEnableOption "the zsh shell, with plugins";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      programs.zsh = {
        enable = true;
        enableCompletion = true;

        shellAliases = {
          "fullupdate" = "sudo ls /dev/null > /dev/null 2>&1 && cd /etc/nixos && git pull && nix flake update && nix fmt && sudo nixos-rebuild switch --flake . |& nom && cd -";
          "update" = "sudo ls /dev/null > /dev/null 2>&1 && cd /etc/nixos && git pull && nix fmt && sudo nixos-rebuild switch --flake . |& nom && cd -";
          "o" = "xdg-open";
          "db" = "distrobox";
          "dbe" = "distrobox enter";
          "cat" = "bat";
          "code" = "codium";
          "reboot" = "systemctl reboot";
          "shutdown" = "systemctl poweroff";
          "poweroff" = "systemctl poweroff";
        };

        # Nixpkgs plugins
        plugins = [
          {
            name = "zsh-autosuggestions";
            src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
          }
          {
            name = "zsh-syntax-highlighting";
            src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
          }
          {
            name = "zsh-completions";
            src = "${pkgs.zsh-completions}/share/zsh-completions";
          }
          {
            name = "zsh-history-substring-search";
            src = "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
          }
        ];

        initContent = lib.mkMerge [
          (lib.mkBefore ''
            export WEZTERM_SHELL_SKIP_ALL=1

            # Source custom plugins
            source ${zsh-256color}/share/zsh/site-functions/zsh-256color/zsh-256color.plugin.zsh
            source ${alias-tips}/share/zsh/site-functions/alias-tips/alias-tips.plugin.zsh
            source ${zsh-bd}/share/zsh/site-functions/zsh-bd/bd.plugin.zsh
            source ${cd-reminder}/share/zsh/site-functions/cd-reminder/cd-reminder.plugin.zsh
            source ${copy-pasta}/share/zsh/site-functions/copy-pasta/copy-pasta.plugin.zsh
            source ${zsh-interactive-cd}/share/zsh/site-functions/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
            source ${wd}/share/zsh/site-functions/wd/wd.plugin.zsh
            source ${zsh-direnv}/share/zsh/site-functions/zsh-direnv/zsh-direnv.plugin.zsh
            source ${zsh-eza-ls-plugin}/share/zsh/site-functions/zsh-eza-ls-plugin/zsh-eza-ls-plugin.plugin.zsh
            source ${zsh-plugin-fd}/share/zsh/site-functions/zsh-plugin-fd/zsh-plugin-fd.plugin.zsh
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
