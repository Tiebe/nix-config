{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.networking.network;
in {
  options = {
    tiebe.system.networking.network = {
      enable = mkEnableOption "network support";
    };
  };

  config = mkIf cfg.enable {
    # Enable networking
    networking.networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
      networking.nameservers = [
      "100.100.100.100"
      "8.8.8.8"
      "1.1.1.1"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
    ];

    systemd.services.NetworkManager-wait-online.enable = false;
    users.users.tiebe.extraGroups = ["networkmanager"];
  };
}
