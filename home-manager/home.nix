{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./packages
    ./services.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "tiebe";
    homeDirectory = "/home/tiebe";
    file.".face".source = config.lib.file.mkOutOfStoreSymlink ./profile.jpg;
  };

  xdg.configFile."sunshine/apps.json".text = builtins.toJSON
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
           detached = [ "${pkgs.util-linux}/bin/setsid ${pkgs.prismlauncher}/bin/prismlauncher" ];
        }
      ];
    };

  home.stateVersion = "23.11";
}
