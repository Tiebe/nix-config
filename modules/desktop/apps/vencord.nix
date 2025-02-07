{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.vencord;
in {
  options = {
    tiebe.desktop.apps.vencord = {
      enable = mkEnableOption "Vencord";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.vencord];
  };
}
