{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.terminal.utils.advanced;

  ayechat = import ./ayechat.nix { inherit (pkgs) python3Packages lib; };

in {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  options = {
    tiebe.terminal.utils.advanced = {
      enable = mkEnableOption "some more advanced utilities for the shell";
    };
  };

  config = mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;

    environment.systemPackages = with pkgs; [
      distrobox
      ayechat
    ];

    programs.adb.enable = true;
    users.users.tiebe.extraGroups = ["adbusers"];
  };
}
