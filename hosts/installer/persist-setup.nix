{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  # Create persistent directory structure
  # These are applied when the installer runs disko and mounts the system
  systemd.tmpfiles.rules = mkIf config.tiebe.installer.enable [
    # Core system directories
    "d /persist/etc/nixos 0755 root root -"
    "d /persist/etc/ssh 0700 root root -"
    "d /persist/etc/openvpn 0755 root root -"
    "d /persist/var/lib/systemd/backlight 0755 root root -"
    "d /persist/var/lib/bluetooth 0755 root root -"
    "d /persist/var/lib/fprint 0755 root root -"
    "d /persist/var/lib/ratbagd 0755 root root -"
    "d /persist/var/lib/monado 0755 root root -"
    "d /persist/var/lib/cups 0755 root root -"
    "d /persist/var/spool/cups 0755 root root -"
    "d /persist/var/lib/containers 0755 root root -"
    "d /persist/windows 0755 root root -"

    # User directories (standard layout)
    "d /persist/home/tiebe 0755 tiebe users -"
    "d /persist/home/tiebe/.config 0755 tiebe users -"
    "d /persist/home/tiebe/.local/share 0755 tiebe users -"
    "d /persist/home/tiebe/.cache 0755 tiebe users -"
    "d /persist/home/tiebe/.var/app 0755 tiebe users -"
    "d /persist/home/tiebe/.mozilla 0700 tiebe users -"
    "d /persist/home/tiebe/.thunderbird 0700 tiebe users -"
    "d /persist/home/tiebe/.gnupg 0700 tiebe users -"

    # Evict-darlings layout (alternative)
    "d /persist/users/tiebe 0755 tiebe users -"
    "d /persist/users/tiebe/config 0755 tiebe users -"
    "d /persist/users/tiebe/home 0755 tiebe users -"
  ];
}
