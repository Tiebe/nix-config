{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./advanced
    ./cmd.nix
    ./dev.nix
    ./gui.nix
  ];
}
