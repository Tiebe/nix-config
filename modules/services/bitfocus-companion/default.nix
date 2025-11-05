{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.bitfocus-companion;

  bitfocus-companion = import ./package.nix {inherit (pkgs) stdenv lib fetchFromGitHub nodejs git python3 udev yarn-berry_4 libusb1 dart-sass electron_36 makeWrapper nix-update-script ps;};

  # bitfocus-companion = bitfocus-companion-original.overrideAttrs (finalAttrs: previousAttrs: {
  #   patches = [./import.patch];
  # });
in {
  options = {
    tiebe.services.bitfocus-companion = {
      enable = mkEnableOption "Bitfocus Companion";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ bitfocus-companion ];
    home-manager.users.tiebe = {
      home.file.".local/share/gnome-shell/extensions/focus-watcher@tiebe.me".source = ./focus-watcher;
      dconf.settings."org/gnome/shell".enabled-extensions = ["focus-watcher@tiebe.me"];

      xdg.desktopEntries = {
        bitfocus-companion = {
          name = "Bitfocus Companion";
          terminal = false;
          exec = "${pkgs.xdg-utils}/bin/xdg-open http://localhost:8000";
        };
      };

      systemd.user.services.bitfocus-companion = {
        Unit = {
          Description = "Start bitfocus companion";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          ExecStart = ''
            ${bitfocus-companion}/bin/bitfocus-companion
          '';
        };
      };
    };

    security.pki.certificates = [
      ''
        -----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUO7oMrpozQKECUjBfTHbEUEc4xh8wDQYJKoZIhvcNAQEL
BQAwKDESMBAGA1UEAwwJbWl0bXByb3h5MRIwEAYDVQQKDAltaXRtcHJveHkwHhcN
MjUxMDE2MTgxNjQyWhcNMzUxMDE2MTgxNjQyWjAoMRIwEAYDVQQDDAltaXRtcHJv
eHkxEjAQBgNVBAoMCW1pdG1wcm94eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBAM6g6M9A50nfAgXu7MriIM9NzP09jrW5X6qeYVNgrQEcvoKIDfCMLN0G
rqR1l8zROZYOwc0+Ry8+0TYlmA4Ua5QxCHjZ+Mx+iYXv1Mi4toyPxmlyCpHrJrtm
lDmj7/8snehU6DS5lMF6AKYc9b6ZPqumrQbpyqcEsKtNi/GsI5J33YzS81JO5Rlb
12Y931wo15JUlBJEEhkBtW+AvcSl2YdSfgSXP0AnuumbuK3jhn0mGKEFhrKIlY4g
HUfwvFMsnECFlIX7RqYXrhwdfcL4WFuTvA/r3QuPyZd1/wy8v/i8yJxhw/NwIDjn
NVKXgxYVgEB9tLCjPOS5GhHIhRdnyPMCAwEAAaNXMFUwDwYDVR0TAQH/BAUwAwEB
/zATBgNVHSUEDDAKBggrBgEFBQcDATAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYE
FNxKOU29PIei8el8btdb/N5LmK8+MA0GCSqGSIb3DQEBCwUAA4IBAQB5eGwT/IPC
8Bl2KSZsmqwyGXTBNcamvYCLfr1kuurZzSr/aSMQbg7qLDN9FdhHjgeCJ2NxTQrT
GmDO85mL1GEGLK4SjCrECzy4PXIG5hrJs9pxUcNa3+/wVZNT9ezJrX3r+Euum3CR
w99hqXkgSjc2Or8KsZoam+O4bSyZQMkNyEXPw4W0bzk/Eeb7ytSAmkGnE+JgHaEG
A6mndTKUti52BESdwW0YoKG+Qo2tnGmJhQos0KWmRRMN48CVTHBPfetXQNvpTZO8
5jB5l5RROyVF9x7Ui3K2hZazkrUjI/DnceZaUtpj+7zMZ4RMj76SYMViUVNSj2jb
5MC4CPTgMlcR
-----END CERTIFICATE-----
      ''
    ];
  };
}
