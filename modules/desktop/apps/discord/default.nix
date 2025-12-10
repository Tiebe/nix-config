{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  krisp-patcher = pkgs.writers.writePython3Bin "krisp-patcher" {
    libraries = with pkgs.python3Packages; [ capstone pyelftools ];
    flakeIgnore = [
      "E501" # line too long (82 > 79 characters)
      "F403" # ‘from module import *’ used; unable to detect undefined names
      "F405" # name may be undefined, or defined from star imports: module
    ];
  } (builtins.readFile ./krisp-patcher.py);

  wrapperScript = pkgs.writeShellScriptBin "discord-wrapper" ''
    set -euxo pipefail

    (sleep 15 && systemctl restart --user bitfocus-companion.service) &

    ${pkgs.findutils}/bin/find -L $HOME/.config/discord -name 'discord_krisp.node' -exec ${krisp-patcher}/bin/krisp-patcher {} +
    ${(pkgs.discord.override {
      withVencord = config.tiebe.desktop.apps.discord.vencord;
    })}/bin/discord "$@"
  '';
in {
  options = {
    tiebe.desktop.apps.discord.enable = lib.mkOption {
      description = "Whether to install Discord, a voice and text chat platform.";
      type = lib.types.bool;
    };
    tiebe.desktop.apps.discord.vencord = lib.mkOption {
      description = "Whether to enable the Vencord client mod.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf config.tiebe.desktop.apps.discord.enable {
    home-manager.users.tiebe = {
      home.packages = [
        wrapperScript
      ];

      xdg.desktopEntries = {
        discord = {
          name = "Discord";
          exec = "${wrapperScript}/bin/discord-wrapper";
          terminal = false;
          icon = ./discord-icon.svg;
        };
      };
    };

    home-manager.users.robbin = {
      home.packages = [
        wrapperScript
      ];

      xdg.desktopEntries = {
        discord = {
          name = "Discord";
          exec = "${wrapperScript}/bin/discord-wrapper";
          terminal = false;
          icon = ./discord-icon.svg;
        };
      };
    };
  };
}
