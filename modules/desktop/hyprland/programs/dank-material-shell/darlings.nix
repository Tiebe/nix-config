{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.hyprland.programs.dankMaterialShell;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # DMS settings, plugins and session state are written at runtime, so they
    # have to survive the ephemeral root.
    home-manager.users.tiebe = {
      config,
      lib,
      ...
    }: let
      # Evict-darlings moves XDG_CONFIG_HOME to <home>/config.
      settingsDir =
        if evictCfg.enable
        then "config/DankMaterialShell"
        else ".config/DankMaterialShell";
      stateDir = ".local/state/DankMaterialShell";
      persistRoot = "/persist${config.home.homeDirectory}";
    in {
      home.file = {
        "${settingsDir}".source =
          config.lib.file.mkOutOfStoreSymlink "${persistRoot}/${settingsDir}";
        "${stateDir}".source =
          config.lib.file.mkOutOfStoreSymlink "${persistRoot}/${stateDir}";
      };

      # mkOutOfStoreSymlink does not create its target, so do it first.
      home.activation.createDankMaterialShellPersistDirs = lib.hm.dag.entryBefore ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
          "${persistRoot}/${settingsDir}" \
          "${persistRoot}/${stateDir}"
      '';
    };
  };
}
