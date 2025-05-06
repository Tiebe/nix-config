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
        personal = {
          address = "tiebe@tiebe.me";
          userName = "tiebe@tiebe.me";
          realName = "Tiebe Groosman";
          primary = true;

          passwordCommand = "cat ${config.age.secrets.emailTiebeAtTiebeMe.path}";

          imap.host = "mail.tiebe.dev";
          smtp.host = "mail.tiebe.dev";

          thunderbird.enable = true;
        };

        work = {
          address = "tiebe@tiebe.dev";
          userName = "tiebe@tiebe.dev";
          realName = "Tiebe Groosman";

          passwordCommand = "cat ${config.age.secrets.emailTiebeAtTiebeDev.path}";

          imap.host = "mail.tiebe.dev";
          smtp.host = "mail.tiebe.dev";

          thunderbird.enable = true;
        };

        gmail = {
          userName = "tiebe.groosman@gmail.com";
          address = "tiebe.groosman@gmail.com";
          flavor = "gmail.com";
          passwordCommand = "cat ${config.age.secrets.emailTiebeGroosmanGmailCom.path}";
          realName = "Tiebe Groosman";

          thunderbird.enable = true;
        };
      };
    };
  };
}
