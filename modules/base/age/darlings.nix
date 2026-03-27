{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.base.age;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    age.secrets = mkIf (evictCfg.enable && cfg.enable) {
      sshPrivate.path = lib.mkForce "${evictCfg.configDir}/ssh/id_ed25519";
      sshPublic.path = lib.mkForce "${evictCfg.configDir}/ssh/id_ed25519.pub";
    };
  };
}
