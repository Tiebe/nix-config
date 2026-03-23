{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.wezterm;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Wezterm config persistence
    home-manager.users.tiebe = { config, ... }: {
      home.file.".config/wezterm".source =
        config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/wezterm";
    };
  };
}
