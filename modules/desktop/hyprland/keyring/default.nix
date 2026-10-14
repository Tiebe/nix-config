{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  hyprland = config.tiebe.desktop.hyprland;
  cfg = hyprland.keyring;
in {
  imports = [./darlings.nix];

  options.tiebe.desktop.hyprland.keyring.enable =
    mkEnableOption "GNOME Keyring for Hyprland sessions";

  config = mkIf (hyprland.enable && cfg.enable) {
    # NixOS adds pam_gnome_keyring to login, which greetd includes for both
    # authentication and session setup. The daemon exposes Secret Service.
    services.gnome.gnome-keyring.enable = true;
  };
}
