{pkgs, ...}: let
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/evening-sky.png";
    sha256 = "0kb87w736abdf794dk9fvqln56axzskxia1g6zdjrqzl7v539035";
  };
in {
  programs.plasma = {
    enable = true;

    /*
    ── Workspace appearance ──────────────────────────────────────
    */
    workspace = {
      colorScheme = "CatppuccinMochaMauve";
      theme = "catppuccin-mocha-blue";
      iconTheme = "Papirus-Dark";
      wallpaper = "${wallpaper}";
      splashScreen = {
        theme = "None";
      };
    };

    /*
    ── Fonts ─────────────────────────────────────────────────────
    */
    fonts = {
      general = {
        family = "Inter";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
      small = {
        family = "Inter";
        pointSize = 8;
      };
      toolbar = {
        family = "Inter";
        pointSize = 10;
      };
      menu = {
        family = "Inter";
        pointSize = 10;
      };
      windowTitle = {
        family = "Inter";
        pointSize = 10;
      };
    };

    /*
    ── KWin ──────────────────────────────────────────────────────
    */
    kwin = {
      borderlessMaximizedWindows = true;
      effects = {
        blur.enable = true;
      };
      virtualDesktops = {
        number = 4;
        rows = 2;
      };
      titlebarButtons = {
        left = [];
        right = [];
      };
    };

    /*
    ── Top panel ─────────────────────────────────────────────────
    */
    panels = [
      {
        location = "top";
        height = 28;
        hiding = "none";
        floating = false;
        opacity = "translucent";
        widgets = [
          {
            name = "org.kde.plasma.mediacontroller";
          }
          "org.kde.plasma.panelspacer"
          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                showDate = true;
                dateFormat = "shortDate";
                use24hFormat = 2;
              };
            };
          }
          "org.kde.plasma.panelspacer"
          {
            name = "org.kde.plasma.systemmonitor";
            config = {};
          }
          "org.kde.plasma.systemtray"
        ];
      }
    ];

    /*
    ── Keyboard shortcuts ────────────────────────────────────────
    */
    shortcuts = {
      kwin = {
        "Window Close" = "Meta+Q";
        "Window Maximize" = "Meta+F";
        "Window Minimize" = "Meta+D";
        "Window Quick Tile Left" = "Meta+Left";
        "Window Quick Tile Right" = "Meta+Right";
        "Window Quick Tile Top" = "Meta+Up";
        "Window Quick Tile Bottom" = "Meta+Down";
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Window to Desktop 1" = "Meta+Shift+1";
        "Window to Desktop 2" = "Meta+Shift+2";
        "Window to Desktop 3" = "Meta+Shift+3";
        "Window to Desktop 4" = "Meta+Shift+4";
      };
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
    };

    /*
    ── App-launch hotkeys ────────────────────────────────────────
    */
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

    hotkeys.commands.toggle-theme = {
      name = "Toggle Dark/Light Theme";
      key = "Meta+Shift+T";
      command = "toggle-catppuccin";
      comment = "Switch between Catppuccin Mocha (dark) and Latte (light)";
    };

    /*
    ── Escape-hatch config ───────────────────────────────────────
    */
    configFile = {
      /*
      Minimal window decorations: no buttons, Breeze for rounded corners
      */
      "kwinrc"."org.kde.kdecoration2" = {
        ButtonsOnLeft = "";
        ButtonsOnRight = "";
        library = "org.kde.breeze";
        theme = "Breeze";
      };
      "breezerc"."Common" = {
        ShadowSize = "ShadowSmall";
        OutlineCloseButton = false;
      };
      /*
      Default terminal
      */
      "kdeglobals"."General" = {
        TerminalApplication = "wezterm";
        TerminalService = "org.wezfurlong.wezterm.desktop";
      };
      /*
      Double-click to open
      */
      "kdeglobals"."KDE".SingleClick = false;
      "kwinrc"."Xwayland"."Scale" = 1.0;
    };
  };
}
