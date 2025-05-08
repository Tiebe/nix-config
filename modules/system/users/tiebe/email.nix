{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.users.tiebe.email;
in {
  options = {
    tiebe.system.users.tiebe.email = {
      enable = mkEnableOption "Email accounts for tiebe";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.tiebe = {
      accounts.email.accounts = {
        Personal = {
          address = "tiebe@tiebe.me";
          userName = "tiebe@tiebe.me";
          realName = "Tiebe Groosman";
          primary = true;

          passwordCommand = "cat ${config.age.secrets.emailTiebeAtTiebeMe.path}";

          imap = {
            host = "mail.tiebe.dev";
            port = 993;
            tls.enable = true;
          };

          smtp = {
            host = "mail.tiebe.dev";
            port = 465;
            tls.enable = true;
          };

          thunderbird.enable = true;
        };

        Work = {
          address = "tiebe@tiebe.dev";
          userName = "tiebe@tiebe.dev";
          realName = "Tiebe Groosman";

          passwordCommand = "cat ${config.age.secrets.emailTiebeAtTiebeDev.path}";

          imap = {
            host = "mail.tiebe.dev";
            port = 993;
            tls.enable = true;
          };

          smtp = {
            host = "mail.tiebe.dev";
            port = 465;
            tls.enable = true;
          };

          thunderbird.enable = true;
        };

        Gmail = {
          userName = "tiebe.groosman@gmail.com";
          address = "tiebe.groosman@gmail.com";
          flavor = "gmail.com";
          passwordCommand = "cat ${config.age.secrets.emailTiebeGroosmanGmailCom.path}";
          realName = "Tiebe Groosman";

          thunderbird.enable = false;
        };
      };
    };
  };
}
