{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [../../modules];

  config = {
    # Use plaintext passwords for testing
    # Force hashedPassword to override hashedPasswordFile from main config
    users.users.tiebe = {
      hashedPassword = lib.mkForce "$y$j9T$uh5tSq/V7t/Af3v/mfCDT1$2Xnbhm.bqsE3k5A0g5fIW.aM/7sJ5pQ2y0.F.PXPoAA"; # "test"
      hashedPasswordFile = lib.mkForce null; # Disable the agenix password file
    };

    # Ensure applications appear in Plasma menu - explicitly add them to system
    environment.systemPackages = with pkgs; [
      firefox
      vscodium
      onlyoffice-desktopeditors
    ];

    # Override all secrets for VM testing (define only what we need)
    age.secrets = lib.mkForce {
      atuin = {
        file = builtins.toFile "dummy" "dummy-key-for-testing";
        owner = "tiebe";
      };
      password = {
        file = builtins.toFile "dummy-password" "test";
      };
      passwordRobbin = {
        file = builtins.toFile "dummy-password-robbin" "test";
      };
      gpgPublic = {
        file = builtins.toFile "dummy-gpg-pub" "dummy";
        owner = "tiebe";
      };
      gpgPrivate = {
        file = builtins.toFile "dummy-gpg-priv" "dummy";
        owner = "tiebe";
      };
      sshPrivate = {
        file = builtins.toFile "dummy-ssh-priv" "dummy-ssh-key";
        mode = "600";
        owner = "tiebe";
        path = "/home/tiebe/.ssh/id_ed25519";
      };
      sshPublic = {
        file = builtins.toFile "dummy-ssh-pub" "dummy-ssh-key.pub";
        mode = "644";
        owner = "tiebe";
        path = "/home/tiebe/.ssh/id_ed25519.pub";
      };
      wgHome = {
        file = builtins.toFile "dummy-wg" "[Interface]\nPrivateKey = dummy\nAddress = 10.0.0.2/24\n\n[Peer]\nPublicKey = dummy\nAllowedIPs = 0.0.0.0/0\nEndpoint = 1.2.3.4:51820";
        path = "/run/agenix/wg-home.conf";
      };
    };

    # Override identity paths to not use YubiKey files
    age.identityPaths = lib.mkForce [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    tiebe = {
      base = {
        age.enable = true; # Keep enabled but with forced empty secrets above
        locale.enable = true;
        nix.enable = true;
      };

      system = {
        boot = {
          systemd-boot.enable = true;
          plymouth.enable = false;
          darlings.enable = true; # Enable erase darlings
        };

        networking = {
          network.enable = true;
          wifi.enable = false; # Disable for VM
          bluetooth.enable = false; # Disable for VM
          tailscale.enable = false; # Disable for VM
          wireguard.enable = true; # Enable WireGuard VPN
        };

        users.tiebe = {
          enable = true;
          email.enable = false; # Disable for VM (requires secrets)
        };

        users.robbin.enable = lib.mkForce false; # Disable robbin for VM

        sound.enable = true;
      };

      theme.catppuccin.enable = true;

      desktop = {
        plasma.enable = true;

        apps = {
          discord.enable = false; # Disabled - requires robbin user setup
          vscode.enable = true;
          firefox.enable = true;
          wezterm.enable = false; # Disabled - conflicts with persistence symlinks in VM
          office.enable = true;
          thunderbird.enable = false; # Requires secrets
          bitwarden.enable = false; # Requires persistence
          steam.enable = false; # Too heavy for VM
          localsend.enable = false;
        };
      };

      terminal = {
        zsh.enable = true;
        utils = {
          basic.enable = true;
          advanced.enable = true;
          fastfetch.enable = true;
        };
      };

      services = {
        podman.enable = true;
        printing.enable = false; # Disable for VM
        gpg.enable = false; # Requires secrets
        lorri.enable = false;
        variety.enable = false;
        devenv.enable = false;
        nextcloud.enable = false; # Requires secrets
      };
    };

    # Ensure home-manager applications appear in Plasma menu
    home-manager.users.tiebe = {
      xdg.enable = true;

      # Make sure home-manager desktop files are discoverable
      # The key is setting XDG_DATA_DIRS before Plasma starts
      home.sessionVariables = {
        XDG_DATA_DIRS = lib.concatStringsSep ":" [
          "$HOME/.nix-profile/share"
          "/run/current-system/sw/share"
          "$XDG_DATA_DIRS"
        ];
      };
    };
  };
}
