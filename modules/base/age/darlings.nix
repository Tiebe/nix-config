{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.base.age;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;

  # Determine SSH directory path based on evict-darlings status
  sshDir =
    if evictCfg.enable
    then "${evictCfg.configDir}/ssh"
    else "/home/tiebe/.ssh";
in {
  config = mkIf (darlings.enable && cfg.enable) {
    age.secrets = mkIf (evictCfg.enable && cfg.enable) {
      sshPrivate.path = lib.mkForce "${evictCfg.configDir}/ssh/id_ed25519";
      sshPublic.path = lib.mkForce "${evictCfg.configDir}/ssh/id_ed25519.pub";
    };

    # Pre-create SSH directory with proper ownership before agenix runs
    # This prevents agenix from creating it as root:root
    systemd.tmpfiles.settings."10-age-ssh"."${sshDir}" = {
      d = {
        user = "tiebe";
        group = "root";
        mode = "0700";
      };
    };
  };
}
