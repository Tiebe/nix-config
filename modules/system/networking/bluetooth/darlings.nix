{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.system.networking.bluetooth;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Bluetooth pairing/trust data (bluez keeps it under /var/lib/bluetooth)
    systemd.tmpfiles.rules = [
      "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    ];

    # bluetoothd uses ProtectSystem=strict + StateDirectory=, which fails to
    # resolve a symlinked state dir ("Too many levels of symbolic links").
    # Disable systemd's own state-dir management since we manage it via the
    # tmpfiles symlink above (same fix as fprintd/systemd-backlight@), but
    # ProtectSystem=strict still makes everything read-only by default, so
    # explicitly reopen /var/lib/bluetooth for writes or pairing data won't
    # actually persist.
    systemd.services.bluetooth.serviceConfig = {
      StateDirectory = "";
      ReadWritePaths = ["/var/lib/bluetooth"];
    };
  };
}
