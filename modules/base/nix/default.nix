{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.tiebe.base.nix;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.base.nix = {
      enable = mkEnableOption "nix config";
    };
  };

  config = mkIf cfg.enable {
    environment.etc = with pkgs; (lib.mapAttrs' (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry);

    programs.nix-ld = {
      enable = true;
    };

    services.envfs.enable = true;

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "reboot-kexec" (builtins.readFile ../reboot-kexec.sh))
    ];

    nixpkgs = {
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        # allowUnfree = true;

        allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "discord"
            "discord-unwrapped"
            "intellij-idea"
            "spotify"
            "steam"
            "steam-unwrapped"
            "lmstudio"
            "antigravity"
            "parsec-bin"
            "obsidian"
            "claude-desktop"
            "claude-code"
            "stremio-linux-shell"
            "profit-taker-analytics"
            # pluto's DisplayLink dock driver
            "displaylink"
            "codex-desktop"
          ];
      };
    };

    nix = {
      # This will add each flake input as a registry
      # To m ake nix3 commands consistent with your flake
      registry.nixpkgs.flake = inputs.nixpkgs;
      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = ["/etc/nix/path"];

      # Collect garbage weekly; keep a month of generations for rollback
      gc = {
        automatic = true;
        dates = "weekly";
        randomizedDelaySec = "45min";
        options = "--delete-older-than 30d";
      };

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = ["nix-command" "flakes"];
        # Deduplicate and optimize nix store
        auto-optimise-store = true;

        substituters = [
          "https://nix-community.cachix.org?priority=20"
          "https://cache.nixos.org?priority=30"
          "https://hyprland.cachix.org"
          "https://cache.lantian.pub/lantian"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
        ];

        trusted-users = [
          "root"
          "tiebe"
        ];

        http-connections = 128;
        max-substitution-jobs = 128;
        cores = 0;
        max-jobs = "auto";
      };
    };
  };
}
