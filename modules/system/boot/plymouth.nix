theme: {
  config,
  pkgs,
  ...
}: {
  boot = {
    # Enable "Silent Boot"
    consoleLogLevel = 0;
    plymouth = {
      enable = true;
      theme = "${theme}";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "${theme}" ];
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
}
