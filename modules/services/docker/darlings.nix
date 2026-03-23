{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.docker;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Rootless Docker stores data in ~/.local/share/docker, not /var/lib/docker
    home-manager.users.tiebe = { config, ... }: {
      xdg.dataFile."docker".source = if evictCfg.enable then
        config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.configDir}/local/share/docker"
      else
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.local/share/docker";
    };
  };
}