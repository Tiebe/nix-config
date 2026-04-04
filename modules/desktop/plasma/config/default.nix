{
  programs.plasma = {
    enable = true;
    shortcuts = {
      ActivityManager.switch-to-activity-2903de61-3d4a-4b4f-bc64-c400afdb965e = [];
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
    };

    hotkeys.commands.rofi-launcher = {
      name = "Rofi Launcher";
      key = "Meta+Shift+Return";
      command = "rofi-launcher";
      comment = "Launch Rofi application launcher";
    };

    hotkeys.commands.wezterm = {
      name = "WezTerm";
      key = "Meta+Return";
      command = "wezterm";
      comment = "Launch WezTerm terminal";
    };

    panels = [
      {
        location = "bottom";
        height = 44;
        widgets = [
          {
            name = "org.kde.plasma.panelspacer";
          }
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                favorites = ["firefox.desktop"];
                launchers = [];
              };
            };
          }
          {
            name = "org.kde.plasma.panelspacer";
          }
          {
            name = "org.kde.plasma.systemtray";
          }
          {
            name = "org.kde.plasma.digitalclock";
          }
        ];
      }
    ];
  };
}
