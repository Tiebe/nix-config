{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.zerogravity;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "L /home/${cfg.user}/.config/zerogravity - - - - /persist/home/${cfg.user}/.config/zerogravity"
    ];
  };
}
