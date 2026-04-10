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
        plymouth.enable = false;
        darlings.enable = true;
        evictDarlings.enable = true;
      };

      networking = {
        network.enable = true;
        wifi.enable = true;
        bluetooth.enable = true;
        tailscale.enable = true;
        wireguard.enable = true;
      };

      users.tiebe = {
        enable = true;
        email.enable = true;
      };

      users.robbin.enable = true;
      sound.enable = true;
    };

    theme.catppuccin.enable = true;

    desktop = {
      plasma.enable = true;

      apps = {
        discord.enable = true;
        discord.vencord = true;
        # vencord.enable = true;
        # legcord.enable = true;
        vscode.enable = true;
        firefox.enable = true;
        wezterm.enable = true;
        media.enable = true;
        parsec.enable = false;
        office.enable = true;
        thunderbird.enable = true;
        #bitwarden.enable = true;
        steam.enable = true;
        intellij.enable = true;
        localsend.enable = true;
        lmstudio.enable = true;
        opencode.enable = true;
        rofi.enable = true;
      };
    };

    terminal = {
      zsh.enable = true;
      utils = {
        basic.enable = true;
        advanced.enable = true;
        fastfetch.enable = true;
        helix.enable = true;
      };
    };

    services = {
      #winapps.enable = true;
      #docker.enable = true;
      podman.enable = true;
      printing.enable = true;
      fingerprint.enable = true;
      gpg.enable = true;
      #lorri.enable = true;
      #variety.enable = true;
      devenv.enable = true;
      nextcloud.enable = true;
      # zerogravity.enable = true;
      ssh-server.enable = true;
    };
  };
}
