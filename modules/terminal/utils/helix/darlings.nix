{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.terminal.utils.helix;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    # Helix config is fully managed by Nix via home-manager programs.helix,
    # so there is no mutable state to persist.
  };
}
