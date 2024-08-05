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
  ];

  programs.gh.enable = true;
}
