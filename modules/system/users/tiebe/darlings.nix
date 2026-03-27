{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.system.users.tiebe;
  darlings = config.tiebe.system.boot.darlings;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    environment.sessionVariables = mkIf (evictCfg.enable && cfg.enable) {
      XDG_CONFIG_HOME = "/users/tiebe/config";
    };
  };
}
