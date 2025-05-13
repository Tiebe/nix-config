{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.nextcloud;
in {
  options = {
    tiebe.services.nextcloud = {
      enable = mkEnableOption "the Nextcloud client";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };
  };
}
