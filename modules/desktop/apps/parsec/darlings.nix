{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.parsec;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Parsec config persistence
    home-manager.users.tiebe = { config, ... }: {
      home.file.".config/parsec".source =
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/parsec";
    };
  };
}
