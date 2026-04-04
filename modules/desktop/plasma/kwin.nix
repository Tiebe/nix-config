{
  programs.plasma = {
    kwin = {
      borderlessMaximizedWindows = true;

      titlebarButtons = {
        left = ["close" "minimize" "maximize"];
        right = [];
      };

      effects = {
        blur.enable = true;
        dimInactive.enable = true;
        translucency.enable = true;
        shakeCursor.enable = true;
      };

      virtualDesktops = {
        number = 4;
        rows = 1;
        names = ["Main" "Work" "Comms" "Media"];
      };
    };

    configFile = {
      # Faster animations
      "kwinrc"."Compositing"."AnimationDurationFactor" = 0.5;

      # Keep tiling with reasonable padding
      "kwinrc"."Tiling"."padding" = 4;
    };
  };
}
