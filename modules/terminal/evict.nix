{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.users.tiebe.evict-your-darlings;
in {
  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      programs.zsh = {
        dotDir = "config/zsh";
        envExtra = ''
          # Run first in .zshenv
          # Forces ZDOTDIR and HOME so that the plugins can be loaded
          export ZDOTDIR="/users/tiebe/config/zsh"
          export HOME="/users/tiebe"
        '';

        initContent = lib.mkBefore ''
          export HOME="/users/tiebe/home"
          cd ~
        '';
      };
    };
  };
}
