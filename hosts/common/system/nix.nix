{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc = with pkgs;
    (lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry)
    // {
      "jdk21".source = jdk21;
    };

  programs.nix-ld.enable = true;

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      android_sdk.accept_license = true;

      jdk21 = {
        enableJavaFx = true;
      };
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

    substituters = [ "https://winapps.cachix.org/" ];
    trusted-public-keys = [ "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g=" ];

  };
  nixpkgs.config = {
  };
}
