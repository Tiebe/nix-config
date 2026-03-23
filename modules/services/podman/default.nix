{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.podman;
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.podman = {
      enable = mkEnableOption "Podman";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    environment.systemPackages = with pkgs; [podman-compose];

    virtualisation.oci-containers.backend = "podman";

    users.users.tiebe.extraGroups = ["podman"];
  };
}
