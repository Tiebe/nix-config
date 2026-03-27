{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.lorri;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {};
}
