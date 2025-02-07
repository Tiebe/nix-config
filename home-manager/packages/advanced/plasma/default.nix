{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  plasmaDir = "${specialArgs.tiebe.base.nix.root}/home-manager/packages/advanced/plasma";
in {
  imports = [
    ./config.nix
  ];

  home.file.".config/kwinoutputconfig.json".source = config.lib.file.mkOutOfStoreSymlink "${plasmaDir}/kwinoutputconfig.json";
}
