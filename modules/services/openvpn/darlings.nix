{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.openvpn;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "L /etc/openvpn - - - - /persist/etc/openvpn"
    ];
  };
}
