{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.orcaslicer;
  # Native Wayland/EGL crashes while rendering plate thumbnails; use the
  # verified X11/XWayland workaround without changing the desktop session.
  package = pkgs.orca-slicer.overrideAttrs (oldAttrs: {
    preFixup =
      (oldAttrs.preFixup or "")
      + ''
        gappsWrapperArgs+=(
          --unset WAYLAND_DISPLAY
          --set GDK_BACKEND x11
          --set mesa_glthread false
        )
      '';
  });
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.orcaslicer = {
      enable = mkEnableOption "orcaslicer";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [package];
  };
}
