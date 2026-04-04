{pkgs, ...}: {
  imports = [
    ./shortcuts.nix
    ./panels.nix
    ./workspace.nix
    ./kwin.nix
    ./apps.nix
    ./data.nix
  ];

  programs.plasma.enable = true;
}
