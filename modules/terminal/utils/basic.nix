{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.terminal.utils.basic;
in {
  options = {
    tiebe.terminal.utils.basic = {
      enable = mkEnableOption "some basic utilities for the shell";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fzf
      wget
      gnupg
      direnv
      inetutils
      nix-output-monitor
      toybox
      usbutils
      bat
      python314
      coreutils
      groff
    ];

    home-manager.users.tiebe = {
      programs.eza.enable = true;

      programs.git = {
        enable = true;
        userName = "Tiebe Groosman";
        userEmail = "tiebe@tiebe.me";
        signing = {
          format = "openpgp";
          key = "53612C9FED81D4EE";
          signByDefault = true;
          signer = "${pkgs.gnupg}/bin/gpg";
        };
        extraConfig = {
          "url \"ssh://git@github.com/\"" = {insteadOf = "https://github.com/";};
          "url \"ssh://forgejo@tiebe.me/\"" = {insteadOf = "https://git.tiebe.me/";};
          init.defaultBranch = "main";
        };
      };
      programs.gh.enable = true;
    };
  };
}
