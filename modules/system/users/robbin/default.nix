{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.users.robbin;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options = {
    tiebe.system.users.robbin = {
      enable = mkEnableOption "user for Robbin";
    };
  };

  config = mkIf cfg.enable {
    users.users = {
      robbin = {
        hashedPasswordFile = config.age.secrets.passwordRobbin.path;
        isNormalUser = true;
        extraGroups = ["wheel" "dialout" "input" ];
      };
    };

    users.defaultUserShell = pkgs.zsh;
    environment.shells = with pkgs; [zsh];
    programs.zsh.enable = true;

    home-manager = {
      extraSpecialArgs = {
        inherit inputs outputs;
        robbin = config.robbin;
      };
      sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
      ];
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
      users = {
        robbin = {
          config,
          pkgs,
          lib,
          ...
        }: {
          programs.home-manager.enable = true;

          home = {
            username = "robbin";
            homeDirectory = "/home/robbin";
          };

          home.stateVersion = "23.11";
        };
      };
    };
  };
}
