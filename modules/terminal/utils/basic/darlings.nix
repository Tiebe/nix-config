{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.terminal.utils.basic;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    programs.ssh = mkIf (evictCfg.enable && cfg.enable) {
      extraConfig = ''
        Host *
          IdentityFile ${evictCfg.configDir}/ssh/id_ed25519
          IdentitiesOnly yes
      '';
    };
  };
}
