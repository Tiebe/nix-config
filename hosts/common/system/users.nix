{
  config,
  inputs,
  outputs,
  pkgs,
  ...
}: {
  users.users = {
    tiebe = {
      hashedPasswordFile = config.age.secrets.password.path;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIle0zbHzFaTojB7DJU5LL76pPSSRY5S+tusC/ZNbi2 tiebe"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCxANoXEguBulOVdL1jCNJYQs/SVUEE1Iq2rokl21lq tiebe"
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "adbusers" "docker" "dialout" "networkmanager"];
    };
  };

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
      custom = config.custom;
    };
    sharedModules = [
      inputs.plasma-manager.homeManagerModules.plasma-manager
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      tiebe = import ../../../home-manager/home.nix;
    };
  };
}
