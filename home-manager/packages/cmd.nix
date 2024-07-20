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
  ];

  programs.gh.enable = true;
}
