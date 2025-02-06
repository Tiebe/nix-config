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
    ./dev.nix
    ./gui.nix
  ];
}
