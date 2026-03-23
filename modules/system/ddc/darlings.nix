{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.system.ddc;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # persistence config
  };
}
