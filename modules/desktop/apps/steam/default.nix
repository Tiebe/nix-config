{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.steam;

  gamescope-kbm = pkgs.gamescope.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ (pkgs.fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/ValveSoftware/gamescope/pull/1897.diff";
      hash = "sha256-qe8BKKj97aaugjE5Ug1RO2uU7+iDdC5JpOFkGYLjV6Q=";
    }) ];
  });
in {
  options = {
    tiebe.desktop.apps.steam = {
      enable = mkEnableOption "Steam";
    };
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };

    environment.systemPackages = with pkgs; [ gamescope-kbm gamemode bubblewrap ];
  };
}
