{pkgs, ...}: {
  home.packages = with pkgs; [
    papirus-icon-theme
    inter
    nerd-fonts.jetbrains-mono
    catppuccin-kde
  ];

  programs.plasma = {
    workspace = {
      colorScheme = "CatppuccinMochaBlue";
      iconTheme = "Papirus-Dark";
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
      };
    };

    fonts = {
      general = {
        family = "Inter";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font";
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
  };
}
