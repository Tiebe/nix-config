{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.system.networking.network;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # NetworkManager connection profiles - covers networks added outside of
    # the declarative wifi.age secret (e.g. via nm-applet), plus runtime
    # state such as known networks and stable MAC address seeds.
    systemd.tmpfiles.rules = [
      "d /persist/etc/NetworkManager/system-connections 0700 root root -"
      "L+ /etc/NetworkManager/system-connections - - - - /persist/etc/NetworkManager/system-connections"
      "d /persist/var/lib/NetworkManager 0700 root root -"
    ];

    # /var/lib/NetworkManager can NOT be a tmpfiles symlink like the path
    # above: NetworkManager.service declares StateDirectory=NetworkManager,
    # and systemd recreates that path as a real directory every time the
    # service starts (it refuses to reuse a symlink there), clobbering
    # whatever tmpfiles set up at boot. That silently drops seen-bssids,
    # secret_key and DHCP lease state on every reboot. Bind-mount the
    # persisted directory instead so systemd always finds a real directory.
    fileSystems."/var/lib/NetworkManager" = {
      device = "/persist/var/lib/NetworkManager";
      fsType = "none";
      options = ["bind"];
    };
  };
}
