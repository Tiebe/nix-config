{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    vscode
    jetbrains-toolbox
    
  ];

  home.sessionPath = [
    "$HOME/.local/share/JetBrains/Toolbox/scripts"
  ];
}
