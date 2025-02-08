{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.lorri;
in {
  options = {
    tiebe.services.lorri = {
      enable = mkEnableOption "the lorri daemon";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      services.lorri.enable = true;
    };
  };
}
