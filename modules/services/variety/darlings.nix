{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.variety;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "L /home/tiebe/.config/variety - - - - /persist/home/tiebe/.config/variety"
    ];
  };
}
