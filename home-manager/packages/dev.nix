{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    vscode
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains-toolbox
  ];
}
