{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.hyprland.sharePicker;
  darlings = config.tiebe.system.boot.darlings;
in {
  # The picker is stateless: the only runtime file it touches is the
  # $XDG_RUNTIME_DIR escape-hatch marker, which must not survive a reboot.
  config = mkIf (darlings.enable && cfg.enable) {};
}
