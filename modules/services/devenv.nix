{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.devenv;
in
{
  options = {
    tiebe.services.devenv = {
      enable = mkEnableOption "devenv.sh";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.devenv ];
  };
}