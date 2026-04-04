{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.fingerprint;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Fingerprint sensor enrollment data persistence
    systemd.tmpfiles.rules = [
      "L /var/lib/fprint - - - - /persist/var/lib/fprint"
    ];

    systemd.services.fprintd.serviceConfig.StateDirectory = "";
  };
}
