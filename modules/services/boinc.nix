{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.boinc;
in {
  options = {
    tiebe.services.boinc = {
      enable = mkEnableOption "";
    };
  };

  config = mkIf cfg.enable {
    services.boinc.enable = true;
    services.boinc.extraEnvPackages = [pkgs.libglvnd pkgs.brotli]; #Rosetta Beta 6.05 needs libGL.so.1 and libbrotlidec.so.1
    users.users.tiebe.extraGroups = ["boinc"]; # Needed for boincmgr to read /var/lib/boinc/gui_rpc_auth.cfg
  };
}
