{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.ratbagd;
  piper = import ./piper.nix {inherit (pkgs) lib meson ninja pkg-config gettext fetchFromGitHub python3 wrapGAppsHook3 gtk3 glib desktop-file-utils appstream-glib adwaita-icon-theme gobject-introspection librsvg;};
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.ratbagd = {
      enable = mkEnableOption "the ratbagd service for g502 mouse";
    };
  };

  config = mkIf cfg.enable {
    services.ratbagd = {
      enable = true;
      package = pkgs.libratbag.overrideAttrs (old: {
        version = "0-unstable-2026-08-18";
        src = pkgs.fetchFromGitHub {
          owner = "libratbag";
          repo = "libratbag";
          rev = "b8d4d3ca1f4d6b23c664ffee2888b8eb669bee21";
          sha256 = "sha256-8V/LIki/tI/9Wi6kuFJp6k1p+moMh8Gc8RNP1BUlZO8=";
        };
      });
    };

    environment.systemPackages = [piper];
  };
}
