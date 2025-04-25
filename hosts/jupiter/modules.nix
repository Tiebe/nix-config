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
      ddc.enable = true;
    };

    theme.catppuccin.enable = true;

    desktop = {
      #theme.enable = true;
      hyprland = {
        enable = true;
        idle.enable = true;
        lock.enable = true;

        animations.enable = true;
        binds.enable = true;
        windowrules.enable = true;

        waybar.enable = true;
        rofi.enable = true;
      };

      apps = {
        steam.enable = true;
        vencord.enable = true;
        wezterm.enable = true;
        vscode.enable = true;
        firefox.enable = true;
        media.enable = true;
        parsec.enable = true;
        office.enable = true;
        minecraft.enable = true;
      };
    };

    terminal = {
      zsh.enable = true;
      utils = {
        basic.enable = true;
        advanced.enable = true;
      };
      fastfetch.enable = true;
    };

    services = {
      winapps.enable = true;
      docker.enable = true;
      printing.enable = true;
      ssh-server.enable = true;
      sunshine.enable = true;
      vr.enable = true;
      gpg.enable = true;
      lorri.enable = true;
      cachix.enable = true;
      openvpn.enable = true;
    };
  };
}
