{
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkIf;
  cfg = config.tiebe.services.windows;
  darlings = config.tiebe.system.boot.darlings;
in {
  config = mkIf (darlings.enable && cfg.enable) {
    tiebe.services.windows.diskPath = mkDefault "/persist/windows/windows.qcow2";
    tiebe.services.windows.nvramPath = mkDefault "/persist/windows/nvram.fd";
  };
}
