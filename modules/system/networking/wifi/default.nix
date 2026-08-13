{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.networking.wifi;

  # Define the maximum number of networks you expect.
  networkCount = 206;
in {
  imports = [
    ./ns
    ./darlings.nix
  ];

  options = {
    tiebe.system.networking.wifi = {
      enable = mkEnableOption "Wi-Fi support";
    };
  };

  config = mkIf cfg.enable {
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

            # For WPA-EAP networks (e.g. eduroam). NetworkManager ignores this
            # section when key-mgmt=wpa-psk, so PSK profiles are unaffected.
            "802-1x" = {
              eap = "$WIFI_EAP_" + builtins.toString i;
              identity = "$WIFI_USERNAME_" + builtins.toString i;
              password = "$WIFI_PASSWORD_" + builtins.toString i;
              "phase2-auth" = "$WIFI_PHASE2_" + builtins.toString i;
            };
          };
        })
        networkCount
      );
    };
  };
}
