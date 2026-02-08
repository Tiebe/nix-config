{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.lmstudio;
in
{
  options = {
    tiebe.desktop.apps.lmstudio = {
      enable = mkEnableOption "LM Studio";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lmstudio
      python313Packages.playwright
      playwright-driver.browsers
      nodejs_25
    ];

    system.activationScripts.playwrightFirefoxSymlink.text = ''
      set -e

      TARGET_DIR="/home/tiebe/.browsers"
      LINK_NAME="$TARGET_DIR/mcp-firefox"
      SOURCE_GLOB="${pkgs.playwright-driver.browsers}/firefox*/"

      mkdir -p "$TARGET_DIR"

      # Remove existing link or directory if it exists
      rm -rf "$LINK_NAME"

      # Create symlink (wildcard expands here)
      ln -s $SOURCE_GLOB "$LINK_NAME"

      chown -R tiebe:users "$TARGET_DIR"
    '';
  };
}