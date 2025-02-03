{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fzf
    wget
    gnupg
    direnv
    inetutils
    nix-output-monitor
    toybox
  ];

  programs.gh.enable = true;
}
