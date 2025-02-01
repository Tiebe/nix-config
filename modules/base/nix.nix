{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  options.custom = {
    root = lib.mkOption {
      type = with lib.types; uniq str;
      example = "/etc/nixos";
      description = ''
        Root of nix flake.
      '';
    };
  };
  config = {
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nix.nixPath = ["/etc/nix/path"];
    environment.etc = with pkgs;
      (lib.mapAttrs'
        (name: value: {
          name = "nix/path/${name}";
          value.source = value.flake;
        })
        config.nix.registry);

    programs.nix-ld.enable = true;

    nixpkgs = {
      # Configure your nixpkgs instance
      config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
        cudaSupport = true;
      };
    };

    # This will add each flake input as a registry
    # To m ake nix3 commands consistent with your flake
    nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

    nix.settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
  };
}
