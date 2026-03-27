{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.obsidian;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules =
      if evictCfg.enable
      then [
        "L+ ${evictCfg.configDir}/obsidian - - - - /persist${evictCfg.configDir}/obsidian"
        "L+ ${evictCfg.configDir}/../.var/app/md.obsidian.Obsidian - - - - /persist${evictCfg.configDir}/../.var/app/md.obsidian.Obsidian"
      ]
      else [
        "L+ /home/tiebe/.config/obsidian - - - - /persist/home/tiebe/.config/obsidian"
        "L+ /home/tiebe/.var/app/md.obsidian.Obsidian - - - - /persist/home/tiebe/.var/app/md.obsidian.Obsidian"
      ];
  };
}
