{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  hyprland = config.tiebe.desktop.hyprland;
  cfg = hyprland.keyring;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && hyprland.enable && cfg.enable) {
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: let
      keyringDir = ".local/share/keyrings";
      persistDir = "/persist${config.home.homeDirectory}/${keyringDir}";
    in {
      home.file.${keyringDir}.source =
        config.lib.file.mkOutOfStoreSymlink persistDir;

      home.activation.createKeyringPersistDir = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p -m 0700 $VERBOSE_ARG "${persistDir}"
      '';
    };
  };
}
