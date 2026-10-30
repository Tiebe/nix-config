{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.rea;
  darlings = config.tiebe.system.boot.darlings;
in {
  # The toolchain itself keeps no state under $HOME. REA is installed and
  # configured by the user, so its cache and agent registrations are theirs to
  # persist.
  config = mkIf (darlings.enable && cfg.enable) {};
}
