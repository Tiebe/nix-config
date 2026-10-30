{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.omp;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.omp = {
      enable = mkEnableOption "Oh My Pi (omp) AI coding agent";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      inputs,
      pkgs,
      ...
    }: {
      imports = [inputs.omp.homeManagerModules.default];

      # APPEND_SYSTEM.md is not inherited by task subagents; always-apply
      # rules are. This rule lands in every session's system prompt, including
      # subagents, and is re-evaluated per agent name.
      home.file.".omp/agent/rules/nixos.md".source = ./config/rules/nixos.md;

      programs.omp = {
        enable = true;
        package = pkgs.callPackage ./package.nix {};
        settings = import ./config/settings.nix;
      };
    };
  };
}
