{ config, lib, ... }: let
  inherit (lib) mkIf;
  cfg = config.tiebe.desktop.apps.vscode;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    systemd.tmpfiles.rules = [
      "L+ /home/tiebe/.config/VSCodium - - - - /persist/home/tiebe/.config/VSCodium"
      "L+ /home/tiebe/.vscode-oss - - - - /persist/home/tiebe/.vscode-oss"
    ];
  };
}
