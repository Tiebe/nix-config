{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.office;
in {
  options = {
    tiebe.desktop.apps.office = {
      enable = mkEnableOption "office utilities";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      onlyoffice-bin
    ];
  };
}
