{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.services.gpg;
  darlings = config.tiebe.system.boot.darlings;
in {
  # GnuPG doesn't need persistence - all files are created automatically
  config = mkIf (darlings.enable && cfg.enable) {};
}
