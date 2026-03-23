{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.base.locale;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # persistence config
  };
}
