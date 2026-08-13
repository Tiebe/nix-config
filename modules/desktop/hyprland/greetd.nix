{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.hyprland;
  greetdCfg = config.tiebe.desktop.hyprland.greetd;
in {
  options = {
    tiebe.desktop.hyprland.greetd = {
      enable = mkEnableOption "greetd with tuigreet for Hyprland";
    };
  };

  config = mkIf (cfg.enable && greetdCfg.enable) {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
          user = "greeter";
        };
      };
    };

    # Prevent getty from conflicting on tty1
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    # tuigreet has no flag to set a static default username, so force its
    # --remember state file to "tiebe" on every boot instead of persisting it.
    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter -"
      "F /var/cache/tuigreet/lastuser 0644 greeter greeter - tiebe"
    ];
  };
}
