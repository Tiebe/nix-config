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

    # ProtectSystem=strict makes everything read-only by default, so
    # explicitly reopen /var/lib/fprint for writes or enrollment data
    # won't actually persist (same fix as bluetooth).
    systemd.services.fprintd.serviceConfig = {
      StateDirectory = "";
      ReadWritePaths = ["/var/lib/fprint"];
    };
  };
}
