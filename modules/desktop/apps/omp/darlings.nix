{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.omp;
  darlings = config.tiebe.system.boot.darlings;
in {
  # ~/.omp state (sessions, history, model cache) lives on the persistent
  # /home subvolume already; only ~/.omp/agent/config.yml is nix-managed
  # (see default.nix), so there is nothing else to relocate under /persist.
  config = mkIf (darlings.enable && cfg.enable) {};
}
