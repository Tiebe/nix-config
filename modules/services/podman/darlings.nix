{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.podman;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # System-level containers storage
    systemd.tmpfiles.rules = [
      "L /var/lib/containers - - - - /persist/var/lib/containers"
    ];
    
    # Rootless containers storage for user
    home-manager.users.tiebe = { config, ... }: {
      home.file.".local/share/containers".source =
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.local/share/containers";
    };
  };
}