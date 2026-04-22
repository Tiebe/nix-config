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
  evictCfg = config.tiebe.system.boot.evictDarlings;

  forgePackage =
    inputs.forgecode.packages.${pkgs.stdenv.hostPlatform.system}.default or null;

  forgeConfigDir =
    if evictCfg.enable
    then "${evictCfg.baseDir}/.forge"
    else "/home/tiebe/.forge";
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
      home.file."${forgeConfigDir}/.forge.toml".source = ./config/.forge.toml;
    };
  };
}
