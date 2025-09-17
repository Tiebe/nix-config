{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.variety;
in {
  options = {
    tiebe.services.variety = {
      enable = mkEnableOption "Variety wallpaper changer";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      home.packages = [
        pkgs.variety
      ];

      xdg.configFile."variety/variety.conf".source = ./variety.conf;

      systemd.user.services.variety = {
        Unit = {
          Description = "Start variety on boot";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.toybox}/bin/pgrep variety || ${pkgs.variety}/bin/variety";
        };
      };
    };
  };
}
