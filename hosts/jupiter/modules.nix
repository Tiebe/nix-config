{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [ ../../modules ];

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

      sound.enable = true;
    };

    users.tiebe.enable = true;

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

    services = {
      winapps.enable = true;
      docker.enable = true;
      printing.enable = true;
      ssh-server.enable = true;
      sunshine.enable = true;
      vr.enable = true;
    };
  };
}
