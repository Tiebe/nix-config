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

      programs.gpg = {
        enable = true;

        scdaemonSettings = {
          disable-ccid = true;
        };
      };

      systemd.user.services.gpg-import-keys = {
        Unit = {
          Description = "Auto import gpg keys";
          After = ["gpg-agent.socket"];
        };

        Service = {
          Type = "oneshot";
          ExecStart = toString (pkgs.writeShellScript "import-gpg-keys" ''
            ${pkgs.gnupg}/bin/gpg --import ${config.age.secrets.gpgPublic.path} ${config.age.secrets.gpgPrivate.path}
          '');
        };

        Install = {WantedBy = ["default.target"];};
      };
    };
  };
}
