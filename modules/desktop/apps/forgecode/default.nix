{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.tiebe.desktop.apps.forgecode;

  forgePackage =
    inputs.forgecode.packages.${pkgs.stdenv.hostPlatform.system}.default or null;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.forgecode = {
      enable = mkEnableOption "ForgeCode";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      lib.optional (forgePackage != null) forgePackage;

    home-manager.users.tiebe = {
      hmConfig,
      lib,
      ...
    }: {
      home.file.".forge/.forge.toml".source = ./config/.forge.toml;
    };
  };
}
