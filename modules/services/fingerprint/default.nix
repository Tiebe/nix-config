{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.fingerprint;
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.fingerprint = {
      enable = mkEnableOption "fingerprint authentication support (fprintd)";
    };
  };

  config = mkIf cfg.enable {
    services.fprintd.enable = true;
  };
}
