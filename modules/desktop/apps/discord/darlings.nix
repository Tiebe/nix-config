{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.discord;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in
{
  config = mkIf (darlings.enable && cfg.enable) {
    # Discord config persistence - use home-manager's config.lib.file
    home-manager.users.tiebe =
      {
        config,
        lib,
        ...
      }:
      {
        home.file.".config/discord".source =
          if evictCfg.enable then
            config.lib.file.mkOutOfStoreSymlink "/persist${evictCfg.baseDir}/.config/discord"
          else
            config.lib.file.mkOutOfStoreSymlink "/persist/home/tiebe/.config/discord";

        # Create the target directories in /persist before symlinks are set up
        home.activation.createDiscordPersistDirs = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p $VERBOSE_ARG \
            ${
              if evictCfg.enable then
                ''"/persist${evictCfg.baseDir}/.config/discord"''
              else
                ''"/persist/home/tiebe/.config/discord"''
            }
        '';
      };
  };
}
