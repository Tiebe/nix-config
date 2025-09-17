{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.gnome;
in {
  options = {
    tiebe.desktop.gnome = {
      enable = mkEnableOption "the GNOME desktop";
    };
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.displayManager.gdm = {
      enable = true;
      debug = true;
    };

    services.desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [pkgs.mutter];
    };

    environment.gnome.excludePackages = with pkgs; [
      atomix # puzzle game
      cheese # webcam tool
      epiphany # web browser
      evince # document viewer
      geary # email reader
      gedit # text editor
      gnome-characters
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
    ];

    nixpkgs.overlays = [
      (final: prev: {
        gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
          mutter = gnomePrev.mutter.overrideAttrs (old: {
            src = pkgs.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "vanvugt";
              repo = "mutter";
              rev = "triple-buffering-v4";
              hash = lib.fakeSha256;
            };
          });
        });
      })
    ];

    environment.systemPackages = with pkgs; [gnomeExtensions.appindicator];
    services.udev.packages = with pkgs; [gnome-settings-daemon];

    home-manager.users.tiebe = {
      dconf = {
        enable = true;
        #settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
        #settings."org/gnome/desktop/interface".cursor-theme = "Adwaita";
        settings = {
          "org/gnome/shell".favorite-apps = ["firefox.desktop"];
          "org/gnome/desktop/wm/keybindings" = {
            switch-windows = ["<Alt>Tab"];
            switch-windows-backward = ["<Shift><Alt>Tab"];
            switch-applications = ["<Super>Tab"];
            switch-applications-backward = ["<Shift><Super>Tab"];
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>Return";
            command = "wezterm";
            name = "WezTerm";
          };

          "org/gnome/system/location".enabled = true;
          "system/locale".region = "nl_NL.UTF-8";
          "org/gnome/desktop/interface".enable-hot-corners = false;
          "org/gnome/mutter".dynamic-workspaces = true;

          "org/gnome/mutter/wayland" = {
            xwayland-allow-grabs = true;
            xwayland-grab-access-rules = ["Remmina" "VirtualBox Machine" "parsecd"];
            experimental-features = ["scale-monitor-framebuffer" "xwayland-native-scaling"];
          };
          "org/gnome/shell/app-switcher".current-workspace-only = true;

          "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = with pkgs.gnomeExtensions; [
              blur-my-shell.extensionUuid
              appindicator.extensionUuid
              user-themes.extensionUuid
            ];
          };
        };
      };

      gtk = {
        enable = true;
      };
    };
  };
}
