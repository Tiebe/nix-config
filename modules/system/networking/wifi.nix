{
  config,
  pkgs,
  ...
}: {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.age.secrets.wifi.path
    ];

#     profiles = {
#       Starlink = {
#         connection = {
#           id = "Starlink";
#           type = "wifi";
#         };
#         ipv4 = {
#           method = "auto";
#         };
#         ipv6 = {
#           addr-gen-mode = "stable-privacy";
#           method = "auto";
#         };
#         wifi = {
#           mode = "infrastructure";
#           ssid = "Starlink";
#         };
#         wifi-security = {
#           key-mgmt = "wpa-psk";
#           psk = "$STARLINK_PSK";
#         };
#       };
#     };
#   };
  };

}