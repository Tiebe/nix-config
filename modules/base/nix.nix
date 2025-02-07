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
      root = lib.mkOption {
        type = with lib.types; uniq str;
        example = "/etc/nixos";
        description = ''
          Root of nix flake.
        '';
        default = "/etc/nixos";
      };
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
      package = pkgs.nix-ld-rs; # only for NixOS 24.05
    };

    nixpkgs = {
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
        cudaSupport = true;
      };
    };

    nix = {
      # This will add each flake input as a registry
      # To m ake nix3 commands consistent with your flake
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = ["/etc/nix/path"];

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;

        extra-substituters = [
          "https://tiebe.cachix.org?priority=10"
          "https://nix-community.cachix.org?priority=20"
          "https://cache.nixos.org?priority=30"
        ];
        trusted-public-keys = [
          "tiebe.cachix.org-1:gIjdnOcIlX9TOKT6StlrNvhCAnQiy9vAoxMfzMhVg54="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
