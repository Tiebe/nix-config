{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.base.locale;
in {
  options = {
    tiebe.base.locale = {
      enable = mkEnableOption "Dutch locale settings";
    };
  };

  config = mkIf cfg.enable {
    # Auto set timezone
    # services.automatic-timezoned.enable = true;
    time.timeZone = "Europe/Amsterdam";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
      LC_MEASUREMENT = "nl_NL.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
      LC_NAME = "nl_NL.UTF-8";
      LC_NUMERIC = "nl_NL.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
      LC_TIME = "nl_NL.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    fonts = {
      packages = with pkgs; [
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        font-awesome
        material-icons
        fira-code
        fira-code-symbols
        nerd-fonts.jetbrains-mono
      ];
    };
  };
}
