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
  servicesModule = file: module "serivces/${file}.nix";
  systemModule = file: module "system/${file}.nix";
  programModule = file: module "programs/${file}.nix";
  desktopModule = file: module "desktop/${file}.nix";
in {
  imports = [
    (baseModule "nix")
    (baseModule "age")
    (baseModule "locale")
    (systemModule "boot/systemdboot")
    (import (systemModule "boot/plymouth") "circle")
    (systemModule "networking/network")
    (systemModule "networking/tailscale")
    (systemModule "networking/wifi")
    (servicesModule "docker")
    (servicesModule "printing")
    (servicesModule "sound")
    (servicesModule "winapps")
    (servicesModule "docker")
    (systemModule "networking/bluetooth")

    (systemModule "users")
    (desktopModule "plasma")

    (programModule "distrobox")
    (programModule "vencord")
  ];

}