{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.codex;
in {
  imports = [
    ./darlings.nix
    inputs.codex-desktop-linux.nixosModules.default
  ];

  options = {
    tiebe.desktop.apps.codex = {
      enable = mkEnableOption "Codex Desktop (ChatGPT Desktop for Linux)";
    };
  };

  config = mkIf cfg.enable {
    programs.codexDesktopLinux = {
      enable = true;
      # `pkgs.codex` follows this flake's nixpkgs input, keeping the CLI in
      # step with the version selected by the normal flake update workflow.
      # It is baked into the launcher/desktop entry so the CLI is found
      # regardless of how the app is started (autostart, launcher, terminal,
      # warm-start), without needing session PATH or re-login.
      cliPackage = pkgs.codex;
    };
  };
}
