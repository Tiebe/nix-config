{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.office;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {};
}
