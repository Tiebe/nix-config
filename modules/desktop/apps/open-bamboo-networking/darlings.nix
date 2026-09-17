{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.open-bamboo-networking;
  darlings = config.tiebe.system.boot.darlings;
in {
  # No dedicated state of its own: the installer writes into BambuStudio's /
  # OrcaSlicer's own config directories, which those apps' own darlings.nix
  # files are responsible for persisting.
  config = mkIf (darlings.enable && cfg.enable) {};
}
