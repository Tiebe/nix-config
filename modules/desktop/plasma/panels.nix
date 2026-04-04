{
  programs.plasma.panels = [
    # ── Top bar ──────────────────────────────────────────────────
    {
      location = "top";
      height = 32;
      floating = true;
      alignment = "center";
      lengthMode = "fill";
      hiding = "none";
      opacity = "translucent";
      widgets = [
        "org.kde.plasma.kickoff"
        "org.kde.plasma.pager"
        "org.kde.plasma.panelspacer"
        "org.kde.windowtitle"
        "org.kde.plasma.panelspacer"
        "org.kde.plasma.systemtray"
        "org.kde.plasma.digitalclock"
      ];
    }

    # ── Bottom dock ──────────────────────────────────────────────
    {
      location = "bottom";
      height = 56;
      floating = true;
      alignment = "center";
      lengthMode = "fit";
      hiding = "dodgewindows";
      widgets = [
        {
          iconTasks = {
            launchers = [
              "applications:org.kde.dolphin.desktop"
              "applications:org.wezfurlong.wezterm.desktop"
              "applications:firefox.desktop"
            ];
          };
        }
      ];
    }
  ];
}
