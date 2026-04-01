{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.networking.wireguard;
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.system.networking.wireguard = {
      enable = mkEnableOption "WireGuard VPN support via NetworkManager";
    };
  };

  config = mkIf cfg.enable {
    # Import the WireGuard configuration using nmcli
    systemd.services.wireguard-import = {
      description = "Import WireGuard configuration into NetworkManager";
      after = ["NetworkManager.service" "agenix.service"];
      wants = ["NetworkManager.service" "agenix.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "wireguard-import" ''
          set -e
          CONFIG_FILE="${config.age.secrets."wgHome.conf".path}"

          # Check if connection already exists
          if ${pkgs.networkmanager}/bin/nmcli connection show wg-home > /dev/null 2>&1; then
            echo "WireGuard connection 'wg-home' already exists, skipping import"
            exit 0
          fi

          # Import the WireGuard configuration
          echo "Importing WireGuard configuration from $CONFIG_FILE"
          ${pkgs.networkmanager}/bin/nmcli connection import type wireguard file "$CONFIG_FILE"
        '';
      };
    };
  };
}
