{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [../../modules];

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

      users.tiebe.enable = true;

      sound.enable = true;
    };

    desktop = {
      gnome.enable = true;
      theme.enable = true;

      apps = {
        vencord.enable = true;
        vscode.enable = true;
        firefox.enable = true;
        wezterm.enable = true;
        media.enable = true;
        parsec.enable = true;
        office.enable = true;
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
      #winapps.enable = true;
      #docker.enable = true;
      podman.enable = true;
      printing.enable = true;
      gpg.enable = true;
      lorri.enable = true;
    };
  };
}
