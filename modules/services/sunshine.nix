{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
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
}
