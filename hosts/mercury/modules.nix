{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  module = path: ../../modules/${path};
  baseModule = file: module "base/${file}.nix";
  servicesModule = file: module "services/${file}.nix";
  systemModule = file: module "system/${file}.nix";
  programModule = file: module "programs/${file}.nix";
  desktopModule = file: module "desktop/${file}";
in {
  imports = [
    (baseModule "nix")
    (baseModule "age")
    (baseModule "locale")

    (systemModule "users")

    (desktopModule "gnome")
    (desktopModule "theme")

    #(programModule "distrobox")
    (programModule "terminal/zsh")
    (programModule "terminal/util")
    (programModule "git")
  ];
}
