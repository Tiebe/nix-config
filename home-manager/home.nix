{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./packages
    ./services.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "tiebe";
    homeDirectory = "/home/tiebe";
    file.".face".source = config.lib.file.mkOutOfStoreSymlink ./profile.jpg;
  };

  home.stateVersion = "23.11";
}
