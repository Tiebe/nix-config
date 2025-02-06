{
  config,
  pkgs,
  ...
}: {
  programs.thunderbird = {
    enable = true;
    package = pkgs.betterbird;
    settings = {};

    profiles = {};
  };
}
