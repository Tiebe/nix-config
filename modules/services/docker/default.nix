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
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.docker = {
      enable = mkEnableOption "Docker";
      rootless = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to run the user-scoped rootless Docker daemon";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = cfg.rootless;
        setSocketVariable = cfg.rootless;
      };
    };

    virtualisation.oci-containers.backend = "docker";

    users.users.tiebe.extraGroups = ["docker"];
    systemd.services."docker".after = ["graphical.target"];
  };
}
