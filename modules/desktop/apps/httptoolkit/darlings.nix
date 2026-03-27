{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.httptoolkit;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # HTTP Toolkit data persistence
    home-manager.users.tiebe = {config, ...}: {
      home.file.".config/httptoolkit".source =
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/httptoolkit";
    };
  };
}
