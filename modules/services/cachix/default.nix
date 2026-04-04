{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.cachix;
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.cachix = {
      enable = mkEnableOption "cachix";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cachix
    ];
  };
}
