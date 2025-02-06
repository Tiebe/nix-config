{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  environment.systemPackages = with pkgs; [
    fzf
    wget
    gnupg
    direnv
    inetutils
    nix-output-monitor
    toybox
    usbutils
    bat
    python314
  ];

  home-manager.users.tiebe = {
    programs.eza.enable = true;
  };
  programs.nix-index-database.comma.enable = true;
}
