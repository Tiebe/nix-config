{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.hyprland;
  programsCfg = config.tiebe.desktop.hyprland.programs;
  dmsCfg = config.tiebe.desktop.hyprland.programs.dankMaterialShell;
in {
  imports = [
    ./darlings.nix
    # Upstream module; its own config is gated on programs.dank-material-shell.enable.
    inputs.dank-material-shell.nixosModules.dank-material-shell
  ];

  options = {
    tiebe.desktop.hyprland.programs.dankMaterialShell = {
      enable = mkEnableOption "DankMaterialShell: bar, launcher, notifications, control center, polkit agent, lock screen and idle handling";

      command = mkOption {
        type = types.str;
        readOnly = true;
        default = lib.getExe config.programs.dank-material-shell.package;
        description = "The `dms` binary, used as `<command> ipc call <target> <function>`.";
      };
    };
  };

  config = mkIf (cfg.enable && dmsCfg.enable) {
    assertions = [
      {
        assertion = !programsCfg.quickshell.enable && !programsCfg.waybar.enable && !programsCfg.swaync.enable && !programsCfg.wlogout.enable;
        message = "tiebe.desktop.hyprland.programs.dankMaterialShell draws its own bar and owns the notification daemon; disable quickshell, waybar, swaync and wlogout before enabling it.";
      }
      {
        assertion = !cfg.lock.enable && !cfg.idle.enable;
        message = "tiebe.desktop.hyprland.programs.dankMaterialShell ships its own lock screen and idle handling; disable tiebe.desktop.hyprland.lock and tiebe.desktop.hyprland.idle before enabling it.";
      }
    ];

    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
    };

    # Battery, brightness and power profile widgets read UPower.
    services.upower.enable = true;
  };
}
