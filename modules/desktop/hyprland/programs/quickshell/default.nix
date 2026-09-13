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
  quickshellCfg = config.tiebe.desktop.hyprland.programs.quickshell;

  # Same Hyprland build the session runs, so hyprctl matches the compositor's IPC.
  hyprctl = "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/bin/hyprctl";

  # The QML is shipped from the store and run with `qs --path`, so the shell
  # never depends on XDG lookup or on whatever PATH the session happens to have.
  shellConfig = pkgs.runCommandLocal "quickshell-shell" {} ''
    cp -r ${./qml} $out
    chmod -R u+w $out

    substituteInPlace $out/Commands.qml.in \
      --replace-fail '@hyprctl@' '${hyprctl}' \
      --replace-fail '@hyprlock@' '${pkgs.hyprlock}/bin/hyprlock' \
      --replace-fail '@systemctl@' '${pkgs.systemd}/bin/systemctl' \
      --replace-fail '@network-settings@' '${pkgs.gnome-control-center}/bin/gnome-control-center' \
      --replace-fail '@bluetooth-settings@' '${pkgs.overskride}/bin/overskride' \
      --replace-fail '@xdg-open@' '${pkgs.xdg-utils}/bin/xdg-open'

    mv $out/Commands.qml.in $out/Commands.qml
  '';
in {
  options = {
    tiebe.desktop.hyprland.programs.quickshell = {
      enable = mkEnableOption "Quickshell (bar, notifications and session menu), replacing waybar, swaync and wlogout";

      package = mkOption {
        type = types.package;
        default = pkgs.quickshell;
        defaultText = lib.literalExpression "pkgs.quickshell";
        description = "Quickshell package used to run the shell.";
      };

      configDir = mkOption {
        type = types.package;
        readOnly = true;
        default = shellConfig;
        description = "Generated QML configuration directory passed to `qs --path`.";
      };

      command = mkOption {
        type = types.str;
        readOnly = true;
        default = "${quickshellCfg.package}/bin/qs --path ${quickshellCfg.configDir}";
        description = "Command that runs or talks to this shell, e.g. `<command> ipc call session toggle`.";
      };
    };
  };

  config = mkIf (cfg.enable && quickshellCfg.enable) {
    assertions = [
      {
        assertion = !programsCfg.waybar.enable && !programsCfg.swaync.enable && !programsCfg.wlogout.enable;
        message = "tiebe.desktop.hyprland.programs.quickshell replaces waybar, swaync and wlogout; disable those modules before enabling it.";
      }
    ];

    # Battery state in the bar comes from UPower.
    services.upower.enable = true;

    home-manager.users.tiebe = {
      home.packages = [
        quickshellCfg.package
        pkgs.gnome-control-center
        pkgs.overskride
      ];

      systemd.user.services.quickshell = {
        Unit = {
          Description = "Quickshell desktop shell";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          ConditionEnvironment = ["WAYLAND_DISPLAY"];
        };

        Service = {
          Type = "simple";
          ExecStart = "${quickshellCfg.command} --no-duplicate";
          Restart = "on-failure";
          RestartSec = 1;
          Slice = "session.slice";
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
