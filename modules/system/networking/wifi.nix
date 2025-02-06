{
  config,
  pkgs,
  lib,
  ...
}: let
  # Define the maximum number of networks you expect.
  networkCount = 205;
in {
  networking.networkmanager.ensureProfiles = {
    # This file will be processed by envsubst.
    environmentFiles = [
      config.age.secrets.wifi.path
    ];

    profiles = builtins.listToAttrs (
      builtins.genList (i: {
        name = "wifi" + builtins.toString i;
        value = {
          connection = {
            id = "$WIFI_SSID_" + builtins.toString i;
            type = "wifi";
          };
          ipv4 = {method = "auto";};
          ipv6 = {
            method = "auto";
            "addr-gen-mode" = "stable-privacy";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$WIFI_SSID_" + builtins.toString i;
            # This variable should be either "true" or "false".
            hidden = "$WIFI_HIDDEN_" + builtins.toString i;
          };
          wifi-security = {
            "key-mgmt" = "$WIFI_KEY_MGMT_" + builtins.toString i;
            # For WPA-PSK networks, WIFI_PSK_i should be nonempty.
            psk = "$WIFI_PSK_" + builtins.toString i;
          };

          # EAP networks dont work yet (like eduroam)
          # "802-1x" = {
          #   eap = "peap";
          #   identity = "$WIFI_USERNAME_" + builtins.toString i;
          #   password = "$WIFI_PASSWORD_" + builtins.toString i;
          #   "phase2-auth" = "mschapv2";
          # };
        };
      })
      networkCount
    );
  };
}
