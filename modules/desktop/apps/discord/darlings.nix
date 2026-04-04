{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.discord;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Discord config persistence - use home-manager's config.lib.file
    home-manager.users.tiebe = {config, ...}: {
      home.file.".config/discord".source =
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/discord";
    };
  };
}
