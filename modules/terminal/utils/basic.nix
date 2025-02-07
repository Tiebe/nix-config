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
    ];

    home-manager.users.tiebe = {
      programs.eza.enable = true;

      programs.git = {
        enable = true;
        userName = "Tiebe Groosman";
        userEmail = "tiebe.groosman@gmail.com";
        extraConfig = {
          "url \"ssh://git@github.com/\"" = {insteadOf = https://github.com/;};
        };
      };
      programs.gh.enable = true;
    };
  };
}
