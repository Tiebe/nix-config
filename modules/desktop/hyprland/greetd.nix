{pkgs, ...}: {
  services.greetd = {
    enable = true;
    vt = 3;
    settings = {
      default_session = {
        user = "tiebe";
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
      };
    };
  };
}
