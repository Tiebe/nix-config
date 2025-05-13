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
        erase-your-darlings.enable = true;
        systemd-boot.enable = true;
      };

      networking = {
        network.enable = true;
        wifi.enable = true;
        bluetooth.enable = true;
        tailscale.enable = true;
      };

      users.tiebe = {
        enable = true;
        email.enable = true;
      };

      sound.enable = true;
      ddc.enable = true;
    };

    theme.catppuccin.enable = true;

    desktop = {
      hyprland = {
        enable = true;
        idle.enable = true;
        lock.enable = true;

        animations.enable = true;
        binds.enable = true;
        windowrules.enable = true;

        greetd.enable = true;

        programs = {
          waybar.enable = true;
          rofi.enable = true;
          swaync.enable = true;
          wlogout.enable = true;
        };
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
        thunderbird.enable = true;
        obsidian.enable = true;
      };
    };

    terminal = {
      zsh.enable = true;
      utils = {
        basic.enable = true;
        advanced.enable = true;

        neovim.enable = true;
        fastfetch.enable = true;
      };
    };

    services = {
      #winapps.enable = true;
      docker.enable = true;
      printing.enable = true;
      ssh-server.enable = true;
      sunshine.enable = true;
      vr.enable = true;
      gpg.enable = true;
      lorri.enable = true;
      cachix.enable = true;
      openvpn.enable = true;
      nextcloud.enable = true;
      windows = {
        enable = true;
        uuid = "03560274-043c-0572-b206-1e0700080009";

        cpu = {
          cores = 9;
          threads = 2;
        };

        memory = 29;
        diskPath = "/persist/windows/windows.qcow2";
        nvramPath = "/persist/windows/nvram.fd";

        sysinfo = {
          bios = {
            vendor = "American Megatrends International, LLC.";
            version = "FK";
            date = "09/27/2024";
          };

          system = {
            manufacturer = "Gigabyte Technology Co., Ltd.";
            product = "Z790 AORUS ELITE AX";
            version = "Default string";
            serial = "Default string";
            family = "Z790 MB";
          };
        };

        gpuModule = "amdgpu";

        pciDevices = [
          {
            type = "pci";
            mode = "subsystem";
            managed = true;
            source = {
              domain = "0x0000";
              bus = "0x03";
              slot = "0x00";
              function = "0x0";
            };
          }
          {
            type = "pci";
            mode = "subsystem";
            managed = true;
            source = {
              domain = "0x0000";
              bus = "0x03";
              slot = "0x00";
              function = "0x1";
            };
          }
          {
            type = "pci";
            mode = "subsystem";
            managed = true;
            source = {
              domain = "0x0000";
              bus = "0x00";
              slot = "0x14";
              function = "0x0";
            };
          }
        ];
      };
    };
  };
}
