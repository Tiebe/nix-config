{
  pkgs,
  lib,
  inputs,
  theme,
  ...
}:
with lib; let
  mkService = lib.recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };
in {
  imports = [./config.nix ./binds.nix ./rules.nix];
  home.packages = with pkgs;
  with inputs.hyprcontrib.packages.${pkgs.system}; [
    libnotify
    wf-recorder
    brightnessctl
    pamixer
    python39Packages.requests
    slurp
    grim
    hyprpicker
    swappy
    grimblast
    hyprpicker
    wl-clip-persist
    wl-clipboard
    pngquant
    cliphist
    foot
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    systemd = {
      variables = ["--all"];
      extraCommands = [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };
  };

  # fake a tray to let apps start
  # https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
}
