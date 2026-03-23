{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.nextcloud;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {};
}
