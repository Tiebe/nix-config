{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./nix.nix
    ./sound.nix
    ./users.nix
    ./locale.nix
    ./services.nix
    ./network.nix
    ./winapps.nix
  ];
}
