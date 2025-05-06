{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.thunderbird;
in {
  options = {
    tiebe.desktop.apps.thunderbird = {
      enable = mkEnableOption "the Thunderbird email client";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      programs.thunderbird = {
        enable = true;
        profiles.main = {
          isDefault = true;
        };
      };
    };
  };
}
