{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./darlings.nix
  ];

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
    environment.systemPackages = [
      (pkgs.discord.override {
        withVencord = config.tiebe.desktop.apps.discord.vencord;
      })
    ];
  };
}
