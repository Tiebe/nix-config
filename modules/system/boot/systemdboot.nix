{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.boot.systemd-boot;
in {
  options = {
    tiebe.system.boot.systemd-boot = {
      enable = mkEnableOption "systemd-boot as bootloader";
    };
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          consoleMode = "max";
        };
        timeout = 2;
      };
    };
  };
}
