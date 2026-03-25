{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.system.networking.bluetooth;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # systemd.tmpfiles.rules = [
    #   "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    # ];
  };
}
