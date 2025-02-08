{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.docker;
in {
  options = {
    tiebe.services.docker = {
      enable = mkEnableOption "Docker";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    virtualisation.oci-containers.backend = "docker";

    users.users.tiebe.extraGroups = ["docker"];
  };
}
