{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.networking.tailscale;
in {
  options = {
    tiebe.system.networking.tailscale = {
      enable = mkEnableOption "tailscale";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      #useRoutingFeatures = "client";
      authKeyFile = config.age.secrets.tailscale.path;
      extraUpFlags = [
        "--login-server" "https://headscale.tiebe.me"
      ];
    };

    networking.firewall.checkReversePath = false;

    systemd.services."tailscaled".after = ["graphical.target"];
  };
}
