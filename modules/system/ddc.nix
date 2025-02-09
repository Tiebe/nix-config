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
  cfg = config.tiebe.system.ddc;
in
{
  options = {
    tiebe.system.ddc = {
      enable = mkEnableOption "DDC monitor control";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = ["i2c-dev"];
    services.udev.extraRules = ''
            KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';

    users.users.tiebe.extraGroups = [ "i2c" ];
  };
}