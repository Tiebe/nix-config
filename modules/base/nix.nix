{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.base.nix;
in {
  options = {
    tiebe.base.nix = {
      enable = mkEnableOption "nix config";
    };
  };

  config = mkIf cfg.enable {
    environment.etc = with pkgs; (lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry);

    programs.nix-ld = {
      enable = true;
    };

    services.envfs.enable = true;

    environment.systemPackages = [(pkgs.writeShellScriptBin "reboot-kexec" (builtins.readFile ./reboot-kexec.sh))];

    nixpkgs = {
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
      };
    };

    nix = {
      # This will add each flake input as a registry
      # To m ake nix3 commands consistent with your flake
      registry.nixpkgs.flake = inputs.nixpkgs;
      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = ["/etc/nix/path"];

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;

        substituters = [
          "https://attic.tiebe.me/main?priority=10"
          "https://nix-community.cachix.org?priority=20"
          "https://cache.nixos.org?priority=30"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "main:S9W2CMEkPauQRH8eQQUk4QMzOa1hr9+KCZRCzqPZJls="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];

        trusted-users = ["root" "tiebe"];

        http-connections = 128;
        max-substitution-jobs = 128;
        cores = 0;
        max-jobs = "auto";
      };
    };
  };
}
