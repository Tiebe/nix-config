{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.ddc;
in {
  options = {
    tiebe.system.ddc = {
      enable = mkEnableOption "DDC monitor control";
    };
  };

  config = mkIf cfg.enable {
    hardware.i2c.enable = true;
    users.users.tiebe.extraGroups = ["i2c"];

    environment.systemPackages = with pkgs.gnomeExtensions; [brightness-control-using-ddcutil];
    home-manager.users.tiebe.dconf.settings."org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [brightness-control-using-ddcutil.extensionUuid];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';
  };
}
