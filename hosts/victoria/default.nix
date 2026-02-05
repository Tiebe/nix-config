{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ./modules.nix
    ./hardware-configuration.nix
  ];

  services.fwupd.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "victoria";

  # kernel patch until https://gitlab.gnome.org/GNOME/gdm/-/issues/974 is resolved
  # boot.kernelPatches = [
  #   {
  #     name = "gdm-amd-gpu-fix";
  #     patch = ./boot_vga.patch;
  #   }
  # ];

  security.pam.services.login.fprintAuth = false;

  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  security.pki.certificates = [
    ''
-----BEGIN CERTIFICATE-----
MIIDcDCCAligAwIBAgIRChaVdhEyc0WtrZIHDxzHzVIwDQYJKoZIhvcNAQELBQAw
QTELMAkGA1UEBhMCWFgxGDAWBgNVBAoTD0hUVFAgVG9vbGtpdCBDQTEYMBYGA1UE
AxMPSFRUUCBUb29sa2l0IENBMB4XDTI1MTIyNTIwMTEyNloXDTM1MTIyNjIwMTEy
NlowQTELMAkGA1UEBhMCWFgxGDAWBgNVBAoTD0hUVFAgVG9vbGtpdCBDQTEYMBYG
A1UEAxMPSFRUUCBUb29sa2l0IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAvQBxt24EwGhF4VZoib35aybPkKaXmahpoIjklrXD9oYncJdhrD8ZgcQB
nQs+kyk5HQ648+jtdNU8HESzPJhbn5UXwMd4t4p3FEk1yhrEKjTqbJ9xGcODoqnT
JKfl/DlUmBi6j1T29zck5n+3R7klBr3laJvcXolLlmp8KjPauH+5Il8ItSvvC1Cd
c8svW5dIngKZgRWnNS3tJIO9tuYiow6+vu82/EUcMMK3nMnQqdcfkCC/t5sJQWsq
nKOrjAcx7b6qip5WHV6G0oDhb1PLdgPTbHpBG6w5AhIlt9eaHRdA4SXERT15X4qT
zPPD3L/QIZU4wqdBrSKJH8NjKnveAQIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/
MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQU4nXCrxEVNyEFS76AnBq2MMZIB5kw
HwYDVR0jBBgwFoAU4nXCrxEVNyEFS76AnBq2MMZIB5kwDQYJKoZIhvcNAQELBQAD
ggEBAHVuHOakapsWbn9wtInC75SHAewh0QzSPcbqEcglkib8IMKRhigKNVcF5pDw
TiQispgV/2/NpjLgZmtAMnyihMJNiCONzba+mFDU+iqQD5NARbkAt2GcKkpV4AXZ
auECVzApv4FmyC/S5P5qv7ebMymL07VwSw7YYJjxMXNebV3m/0dTdCKy1K5xTLb+
XYRSYRkJTbTMujNj7AY5xxpckWY+GWIZTKjzxoLaI27CKDSjjxCF0yenqC55O4wr
AL1hfRn39kn/u5h8/Rw4nhgoncWXJ2eVBLJk5etRLpmM2AYvijRMYwXVWu9nvbNn
T2G75N+4RmEeIeBtVg5O5wruBE4=
-----END CERTIFICATE-----
    ''
  ];

  hardware.rtl-sdr.enable = true;
  users.users.tiebe.extraGroups = [ "plugdev" ];

  networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
