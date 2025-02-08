{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.gpg;
in {
  options = {
    tiebe.services.gpg = {
      enable = mkEnableOption "GPG service";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
      };

      home.file = {
        ".gnupg/gpg.conf".source = ./gpg.conf;
        ".gnupg/scdaemon.conf".text = "disable-ccid";
        #".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
      };
    };
  };
}
