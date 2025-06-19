{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.users.tiebe.evict-your-darlings;

  firefox = pkgs.firefox.overrideAttrs (a: {
    buildCommand =
      a.buildCommand
      + ''
        wrapProgram "$executablePath" \
          --set 'HOME' '/users/tiebe/config'
      '';
  });
in {
  config = mkIf cfg.enable {
    programs.firefox = {
      package = firefox;
    };
  };
}
