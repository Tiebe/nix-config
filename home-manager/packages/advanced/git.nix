{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Tiebe Groosman";
    userEmail = "tiebe.groosman@gmail.com";
    extraConfig = {
      "url \"ssh://git@github.com/\"" = {insteadOf = https://github.com/;};
    };
  };
}
