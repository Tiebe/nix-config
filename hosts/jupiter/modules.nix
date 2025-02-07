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
  # imports = [ ];

  config.tiebe = {
    base = {
      age.enable = true;
      locale.enable = true;
      nix.enable = true;
    };

    system = {
      boot = {
        systemd-boot.enable = true;
        plymouth.enable = true;
      };

      networking = {
        network.enable = true;
        wifi.enable = true;
        bluetooth.enable = true;
        tailscale.enable = true;
      };
    };

    desktop = {
      gnome.enable = true;
      theme.enable = true;

      apps = {
        steam.enable = true;
        vencord.enable = true;
      };
    };

    terminal = {
      zsh.enable = true;
      utils = {
        basic.enable = true;
        advanced.enable = true;
      };
    };
  };

  imports = [
    ../../modules
    (servicesModule "docker")
    (servicesModule "printing")
    (servicesModule "sound")
    (servicesModule "sshserver")
    (servicesModule "winapps")
    (servicesModule "docker")

    (systemModule "users")

    (servicesModule "sunshine")
    (servicesModule "vr")
  ];
}
