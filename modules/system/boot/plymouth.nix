{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.boot.plymouth;
in {
  options = {
    tiebe.system.boot.plymouth = {
      enable = mkEnableOption "plymouth for boot animations";
      theme = lib.mkOption {
        type = with lib.types; uniq str;
        example = "circle";
        description = "Theme to use for boot animation";
        default = "circle";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      # Enable "Silent Boot"
      consoleLogLevel = 0;
      plymouth = {
        enable = true;
        #theme = "${theme}";
        themePackages = with pkgs; [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = ["${cfg.theme}"];
          })
        ];
      };
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "i915.fastboot=1"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };
  };
}
