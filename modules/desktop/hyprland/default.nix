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
in {
  options = {
    tiebe.desktop.hyprland = {
      enable = mkEnableOption "the Hyprland compositor";
    };
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };

    # XDG portal for screen sharing, file pickers, etc.
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    # Essential Wayland session packages
    environment.systemPackages = with pkgs; [
      wl-clipboard
      cliphist
      grim
      slurp
      brightnessctl
      playerctl
      libnotify
      polkit_gnome
      networkmanagerapplet
      pavucontrol
      blueman
    ];

    # Polkit agent for auth dialogs
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # Enable dconf for GTK settings
    programs.dconf.enable = true;

    home-manager.users.tiebe = {
      services.hyprpaper.enable = true;

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        systemd = {
          enable = true;
          variables = ["--all"];
        };
        settings = {
          # Monitor configuration
          monitor = [
            "desc:GIGA-BYTE TECHNOLOGY CO. LTD. GS32Q 23342B600296, 2560x1440@165, 0x0, 1"
            "desc:AOC Q27G2SG4 XFXP6HA016617, 2560x1440@155, -2560x0, 1"
            "desc:Hewlett Packard HP 22cwa 6CM64808DT, 1920x1080x60, 2560x0, 1"
            ", preferred, auto, 1"
          ];

          # General appearance
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 3;
            "col.active_border" = "rgb(cba6f7)"; # mauve
            "col.inactive_border" = "rgb(313244)"; # surface0
            layout = "dwindle";
            allow_tearing = false;
          };

          # Decoration
          decoration = {
            rounding = 14;
            active_opacity = 1.0;
            inactive_opacity = 0.92;
            blur = {
              enabled = true;
              size = 6;
              passes = 3;
              new_optimizations = true;
              xray = false;
              ignore_opacity = true;
            };
            shadow = {
              enabled = true;
              range = 20;
              render_power = 3;
              color = "rgba(1a1a2eee)";
            };
          };

          # Input
          input = {
            kb_layout = "us";
            follow_mouse = 1;
            sensitivity = 0;
            accel_profile = "flat";
            touchpad = {
              natural_scroll = true;
              tap-to-click = true;
              drag_lock = true;
            };
          };

          # Dwindle layout
          dwindle = {
            pseudotile = true;
            preserve_split = true;
            force_split = 2;
          };

          # Master layout
          master = {
            new_status = "master";
          };

          # Misc
          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
          };

          # Clipboard history
          exec-once = [
            "wl-paste --type text --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
            "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
          ];

          # Cursor
          cursor = {
            no_hardware_cursors = true;
          };
        };
      };
    };
  };

  imports = [
    ./darlings.nix
    ./animations.nix
    ./binds.nix
    ./windowrules.nix
    ./idle.nix
    ./lock.nix
    ./greetd.nix
    ./programs
  ];
}
