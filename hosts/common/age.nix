{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  agePath = path: ../../secrets/${path};
in {
  imports = [inputs.agenix.nixosModules.age];

  age.ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${pkgs.rage}/bin/rage";

  environment.systemPackages = with pkgs; [
      age-plugin-yubikey
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-manager
      inputs.agenix.packages.x86_64-linux.default
  ];

  services.yubikey-agent.enable = true;
  services.pcscd.enable = true;

  age = {
    secrets = {
      password.file = agePath "password.age";
    };

    identityPaths = [
      (agePath "keys/age-yubikey-identity-c67fa313.txt")
    ];
  };
}