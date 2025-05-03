{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.base.age;

  agePath = path: ../../secrets/${path};
in {
  imports = [inputs.agenix.nixosModules.age];

  options = {
    tiebe.base.age = {
      enable = mkEnableOption "age for secret decoding";
    };
  };

  config = mkIf cfg.enable {
    age.ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${pkgs.rage}/bin/rage";

    environment.systemPackages = with pkgs; [
      age-plugin-yubikey
      gawk
      gnupg
      inputs.agenix.packages.x86_64-linux.default
    ];

    services.pcscd.enable = true;

    age = {
      secrets = {
        password.file = agePath "password.age";
        tailscale.file = agePath "tailscale.age";
        wifi.file = agePath "wifi.age";
        atuin.file = agePath "atuin.age";
        atuin.owner = "tiebe";
        emailTiebeAtTiebeMe.file = agePath "email/tiebe.tiebe.me.age";
        emailTiebeAtTiebeMe.owner = "tiebe";
        emailTiebeAtTiebeDev.file = agePath "email/tiebe.tiebe.dev.age";
        emailTiebeAtTiebeDev.owner = "tiebe";
        emailTiebeGroosmanGmailCom.file = agePath "email/tiebe.groosman.gmail.com.age";
        emailTiebeGroosmanGmailCom.owner = "tiebe";
      };

      identityPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        (agePath "keys/age-yubikey-identity-c67fa313.txt")
        (agePath "keys/age-yubikey-identity-9b188c32.txt")
      ];
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # system.activationScripts.waitForYubikey = {
    #   text = ''
    #     source ${config.system.build.setEnvironment}
    #     PRESENT=true
    #     echo Waiting for Yubikey...

    #     while $PRESENT
    #     do
    #         RESULT=`2>&1 gpg2 --card-status`
    #         echo $RESULT
    #         CARD_ABSENT=`echo $RESULT | grep "OpenPGP card not available"`
    #         if [ -z "''${CARD_ABSENT}" ]
    #         then
    #             SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
    #             IFS=$'\n'      # Change IFS to newline char
    #             lines=($RESULT)
    #             IFS=$SAVEIFS   # Restore original IFS
    #             SIGNATURE=`echo ''${lines[17]} | awk -F":" '{print $2}'`
    #             if [ -z "''${SIGNATURE}" ]
    #             then
    #                 PRESENT=true
    #                 sleep 1
    #             else
    #                 echo Yubikey found!
    #                 PRESENT=false
    #             fi
    #         else
    #              PRESENT=true
    #              sleep 1
    #         fi
    #     done
    #   '';
    # };

    system.activationScripts.agenixInstall.deps = [
      "agenixNewGeneration"
      "specialfs"
      #"waitForYubikey"
    ];
  };
}
