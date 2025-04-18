{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.openvpn;
in {
  options = {
    tiebe.services.openvpn = {
      enable = mkEnableOption "OpenVPN";
    };
  };

  config = mkIf cfg.enable {
    services.openvpn.servers = {
      tryhackme = {
        autoStart = false;
        config = builtins.readFile ./tryhackme.ovpn;
      };
    };
  };
}
