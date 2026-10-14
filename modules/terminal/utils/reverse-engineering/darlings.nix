{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.terminal.utils.reverse-engineering;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Analysis tools add no user configuration; REA setup remains user-managed.
  };
}
