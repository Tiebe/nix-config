{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fzf
    wget
    sops
    gnupg
    direnv
    inetutils
    nix-output-monitor
  ];

  programs.gh.enable = true;
}
