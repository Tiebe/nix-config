{
  config,
  pkgs,
  ...
}: {
  boot = {
    # Enable "Silent Boot"
    consoleLogLevel = 0;
    plymouth = {
      enable = true;
      theme = "circle";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = ["circle"];
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
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      timeout = 0;
    };
  };
}
