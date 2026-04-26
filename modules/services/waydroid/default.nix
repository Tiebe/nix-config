{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.services.waydroid;
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.waydroid = {
      enable = mkEnableOption "Waydroid Android container runtime";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.waydroid.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];

    users.users.tiebe.extraGroups = ["adbusers"];
    programs.adb.enable = true;
  };
}
