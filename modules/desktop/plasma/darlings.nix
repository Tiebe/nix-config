{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.plasma;
  darlings = config.tiebe.system.boot.darlings;
in {
  imports = [./config/darlings.nix];

  config = mkIf (darlings.enable && cfg.enable) {
    # NixOS-level plasma persistence (user state handled in config/darlings.nix)
  };
}
