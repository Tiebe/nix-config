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
  cfg = config.tiebe.services.sunshine;
in
{
  options = {
    tiebe.services.sunshine = {
      enable = mkEnableOption "Sunshine, a remote desktop/remote gaming service";
    };
  };

  config = mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    home-manager.users.tiebe = {
      xdg.configFile."sunshine/apps.json".text =
        builtins.toJSON
        {
          env = "/run/current-system/sw/bin";
          apps = [
            {
              name = "Steam";
              output = "steam.txt";
              detached = ["${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"];
              image-path = "steam.png";
            }
            {
              name = "PrismLauncher";
              output = "primslauncher.txt";
              detached = ["${pkgs.util-linux}/bin/setsid ${pkgs.prismlauncher}/bin/prismlauncher"];
            }
          ];
        };
    };
  };
}