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

    # V1 registries.conf schema; this is exactly what the removed
    # `virtualisation.containers.registries.search` shim expanded to.
    virtualisation.containers.registries.settings.registries.search.registries = ["docker.io"];

    users.users.tiebe.extraGroups = ["podman"];
  };
}
