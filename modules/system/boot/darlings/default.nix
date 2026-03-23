{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.boot.darlings;
in {
  options = {
    tiebe.system.boot.darlings = {
      enable = mkEnableOption "Erase your darlings";
    };
  };

  config = mkIf cfg.enable {
    # Core boot persistence - system-wide settings
    environment.etc = {
      nixos.source = "/persist/etc/nixos";
      machine-id.source = "/persist/etc/machine-id";
    };

    security.sudo.extraConfig = "Defaults lecture=\"never\"";

    users.mutableUsers = false;
  };
}
