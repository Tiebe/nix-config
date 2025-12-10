{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.ratbagd;
  piper = import ./piper.nix { inherit (pkgs) lib meson ninja pkg-config gettext fetchFromGitHub python3 wrapGAppsHook3 gtk3 glib desktop-file-utils appstream-glib adwaita-icon-theme gobject-introspection librsvg; };
in
{
  options = {
    tiebe.services.ratbagd = {
      enable = mkEnableOption "the ratbagd service for g502 mouse";
    };
  };

  config = mkIf cfg.enable {
    services.ratbagd = {
      enable = true;
      package = (pkgs.libratbag.overrideAttrs (old: {
        version = "unstable-2025-11-07";
        src = pkgs.fetchFromGitHub {
          owner = "libratbag";
          repo = "libratbag";
          rev = "78d1124c3e7b992470017ab8a5b5af009745fe4f";
          sha256 = "sha256-+aCORAue2hs8DPcWPszzMwGC9SMfJ/A0zpn7tCwuD9Y=";
        };
      }));
    };

    environment.systemPackages = [ piper ];  
  };
}