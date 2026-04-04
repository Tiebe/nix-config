# Plan: Rice KDE Plasma on NixOS

## Context

NixOS flake config repo. User wants a riced KDE Plasma setup on the `victoria` host. System uses "erase your darlings" (ephemeral root, opt-in persistence) and "evict your darlings" (two-tier home: config vs personal data). All config is declarative Nix.

### Key architectural constraints
- Modules follow `tiebe.<category>.<name>` option pattern with `mkIf cfg.enable`
- Darlings files must check BOTH `darlings.enable && cfg.enable`
- Imports must be STATIC — never conditional
- `plasma/config/darlings.nix` exists but is NOT imported anywhere yet
- plasma-manager is already wired as a sharedModule
- Catppuccin NixOS + home-manager modules are already imported
- evictDarlings paths: `baseDir=/users/tiebe`, `configDir=/users/tiebe/config` (= HOME), `homeDir=/users/tiebe/home`

### Files to modify
1. `modules/desktop/plasma/default.nix` — Switch to Wayland, add font packages
2. `modules/desktop/plasma/config/default.nix` — Complete rewrite with plasma-manager rice
3. `modules/desktop/plasma/config/darlings.nix` — Persistence for KDE runtime state
4. `modules/desktop/plasma/darlings.nix` — Import config/darlings.nix, add NixOS-level persistence
5. `modules/desktop/theme/catppuccin/default.nix` — Add KDE-specific theming (Kvantum, color scheme, SDDM, cursors, icons)
6. `modules/desktop/theme/catppuccin/darlings.nix` — Persistence for Kvantum config

### Existing file contents (for edit reference)

**modules/desktop/plasma/default.nix** (39 lines):
- Lines 26: `services.displayManager.defaultSession = "plasmax11";` → change to `"plasma"`
- Lines 29-31: excludePackages — keep
- Lines 33-35: home-manager imports ./config — keep
- Line 38: imports darlings.nix — keep

**modules/desktop/plasma/config/default.nix** (54 lines):
- Complete rewrite needed. Currently has bottom panel, basic shortcuts.

**modules/desktop/plasma/darlings.nix** (13 lines):
- Empty stub. Needs NixOS-level persistence + import of config/darlings.nix

**modules/desktop/plasma/config/darlings.nix** (13 lines):
- Empty stub. Needs home-manager persistence for KDE state dirs

**modules/desktop/theme/catppuccin/default.nix** (45 lines):
- Already has mocha flavor, rofi/waybar/wlogout catppuccin, Bibata cursor
- Needs: Kvantum, KDE color scheme, icon theme, SDDM catppuccin, accent color, toggle script

**modules/desktop/theme/catppuccin/darlings.nix** (13 lines):
- Empty stub. May need Kvantum config persistence.

---

## Step 1: Switch to Wayland + add font/icon packages

**File**: `modules/desktop/plasma/default.nix`

**Changes**:
1. Change `defaultSession` from `"plasmax11"` to `"plasma"` (Wayland)
2. Add `services.displayManager.sddm.wayland.enable = true;`
3. Add font packages: `pkgs.inter`, `pkgs.nerd-fonts.jetbrains-mono`
4. Add icon package: `pkgs.papirus-icon-theme`
5. Add `environment.systemPackages` with the wallpaper toggle script (shell script to switch between Mocha/Latte)
6. Remove `services.xserver.enable = true;` — not needed for pure Wayland Plasma 6

**Verification**: `nix fmt && nix flake check`

---

## Step 2: Rewrite plasma-manager config

**File**: `modules/desktop/plasma/config/default.nix`

**Complete rewrite** with all rice settings:

### Panel
```nix
panels = [
  {
    location = "top";
    height = 28;
    floating = false;
    hiding = "none";
    widgets = [
      {
        name = "org.kde.plasma.digitalclock";
        config.Appearance = {
          showDate = true;
          dateFormat = "custom";
          customDateFormat = "ddd d MMM";
        };
      }
      { name = "org.kde.plasma.panelspacer"; }
      {
        name = "org.kde.plasma.systemtray";
      }
      {
        name = "org.kde.plasma.mediacontroller";
      }
    ];
  }
];
```

### Workspace
```nix
workspace = {
  colorScheme = "CatppuccinMochaMauve";
  theme = "breeze-dark";
  iconTheme = "Papirus-Dark";
  cursor = {
    theme = "catppuccin-mocha-mauve-cursors";
    size = 24;
  };
  wallpaper = <url-to-wallpaper>;
};
```

### KWin
```nix
kwin = {
  virtualDesktops = {
    rows = 1;
    number = 4;
    names = ["I" "II" "III" "IV"];
  };
  borderlessMaximizedWindows = true;
  effects = {
    blur.enable = true;
  };
  titlebarButtons = {
    left = [];
    right = [];
  };
};
```

### Fonts
```nix
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
```

### Shortcuts
Keep existing rofi + wezterm hotkeys, add:
```nix
shortcuts = {
  kwin = {
    "Window Close" = "Meta+Q";
    "Window Maximize" = "Meta+Up";
    "Window Quick Tile Bottom" = "Meta+Down";
    "Window Quick Tile Left" = "Meta+Left";
    "Window Quick Tile Right" = "Meta+Right";
    "Window Quick Tile Top Left" = "Meta+Ctrl+Left";
    "Window Quick Tile Top Right" = "Meta+Ctrl+Right";
    "Window Quick Tile Bottom Left" = "Meta+Ctrl+Shift+Left";
    "Window Quick Tile Bottom Right" = "Meta+Ctrl+Shift+Right";
    "Switch to Desktop 1" = "Meta+1";
    "Switch to Desktop 2" = "Meta+2";
    "Switch to Desktop 3" = "Meta+3";
    "Switch to Desktop 4" = "Meta+4";
    "Window to Desktop 1" = "Meta+Shift+1";
    "Window to Desktop 2" = "Meta+Shift+2";
    "Window to Desktop 3" = "Meta+Shift+3";
    "Window to Desktop 4" = "Meta+Shift+4";
  };
};
```

### configFile escape hatch for settings not directly supported
```nix
configFile = {
  # Window decorations: no titlebar
  "kwinrc"."Windows"."BorderlessMaximizedWindows" = true;
  
  # Blur settings
  "kwinrc"."Effect-blur"."BlurStrength" = 12;
  "kwinrc"."Effect-blur"."NoiseStrength" = 2;
  
  # Window border/decoration
  "kwinrc"."org.kde.kdecoration2"."BorderSize" = "Normal";
  "kwinrc"."org.kde.kdecoration2"."BorderSizeAuto" = false;
  "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "";
  "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight" = "";
  "kwinrc"."org.kde.kdecoration2"."ShowToolTips" = false;
  
  # Transparency/compositing
  "kwinrc"."Compositing"."GLCore" = true;
  "kwinrc"."Compositing"."Backend" = "OpenGL";
  
  # Edge tiling
  "kwinrc"."Windows"."ElectricBorderMaximize" = true;
  "kwinrc"."Windows"."ElectricBorderTiling" = true;
  "kwinrc"."Windows"."ElectricBorderCornerRatio" = "0.25";

  # Panel opacity / transparency
  "kdeglobals"."General"."TerminalApplication" = "wezterm";
  "kdeglobals"."General"."TerminalService" = "org.wezfurlong.wezterm.desktop";
};
```

**Verification**: `nix fmt && nix flake check`

---

## Step 3: Catppuccin KDE theming

**File**: `modules/desktop/theme/catppuccin/default.nix`

**Changes**:
1. Add `catppuccin.accent = "mauve";` to home-manager config
2. Add `catppuccin.kvantum.enable = true;` for Qt theming
3. Add `qt.style.name = "kvantum";` to home-manager config
4. Switch cursor to catppuccin cursor: `catppuccin.cursors.enable = true; catppuccin.cursors.accent = "mauve";` — remove Bibata cursor
5. Add SDDM catppuccin theming at NixOS level: `catppuccin.sddm.enable = true; catppuccin.sddm.flavor = "mocha"; catppuccin.sddm.accent = "mauve";`
6. Add icon theme package: `pkgs.papirus-icon-theme` + `catppuccin-papirus-folders` (the catppuccin module may handle this)
7. Add dark/light toggle script as a home-manager package:
   - Script that toggles between Mocha and Latte using `plasma-apply-colorscheme`
   - Switches Kvantum theme variant
   - Can be bound to a hotkey

**Verification**: `nix fmt && nix flake check`

---

## Step 4: Add toggle hotkey for dark/light

**File**: `modules/desktop/plasma/config/default.nix`

Add hotkey command for the toggle script (keybind in plasma-manager):
```nix
hotkeys.commands.toggle-theme = {
  name = "Toggle Dark/Light Theme";
  key = "Meta+Shift+T";
  command = "catppuccin-toggle";
  comment = "Toggle between Catppuccin Mocha and Latte";
};
```

**Verification**: `nix fmt && nix flake check`

---

## Step 5: Wallpaper

Find a suitable Catppuccin-themed wallpaper URL. Options:
- Use a Catppuccin official wallpaper from their GitHub releases
- Use a moody purple/dark wallpaper that matches the Mauve accent

Download to `modules/desktop/theme/catppuccin/wallpaper.jpg` or reference via URL in plasma-manager `workspace.wallpaper`.

plasma-manager `workspace.wallpaper` expects a local path, so we'll need to fetch it as a Nix derivation or store it in the repo.

**Verification**: `nix fmt && nix flake check`

---

## Step 6: Darlings persistence

### `modules/desktop/plasma/darlings.nix`
Add import for `./config/darlings.nix` and NixOS-level persistence (SDDM state if needed).

### `modules/desktop/plasma/config/darlings.nix`
Home-manager persistence for KDE runtime state directories:
- `~/.config/kde.org/` — KDE app settings
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc` — panel/widget state (may conflict with plasma-manager declarative config — SKIP if plasma-manager is managing this)
- `~/.local/share/kwalletd/` — KDE wallet data
- `~/.local/share/kscreen/` — monitor configuration
- `~/.local/share/kactivitymanagerd/` — activity state

Since plasma-manager is declaratively managing panel/workspace config, we should only persist:
- **kwalletd** data (secrets/passwords)
- **kscreen** data (monitor layout)
- **baloo** index (file search, though it regenerates)

Follow the steam/opencode darlings pattern exactly.

### `modules/desktop/theme/catppuccin/darlings.nix`
May need persistence for:
- `~/.config/Kvantum/` — Kvantum style selection

**Verification**: `nix fmt && nix flake check`

---

## Step 7: Final validation

1. `nix fmt`
2. `nix flake check`
3. `nix build .#nixosConfigurations.victoria.config.system.build.toplevel --dry-run`
4. Review all changes for consistency

---

## Risk Assessment

1. **plasma-manager option names**: The exact attribute names may differ from what's documented — need to verify against the actual module source
2. **Catppuccin color scheme name**: `CatppuccinMochaMauve` vs `Catppuccin-Mocha-Mauve` — need to check what the catppuccin/nix module actually produces
3. **configFile values**: Some KWin settings may need specific value types (int vs string vs bool)
4. **Wallpaper path**: plasma-manager may need absolute path to a file in the Nix store
5. **Kvantum + plasma-manager interaction**: Kvantum may override some plasma-manager workspace settings
6. **SDDM catppuccin**: The catppuccin NixOS module may require specific SDDM configuration that conflicts with our existing SDDM setup
