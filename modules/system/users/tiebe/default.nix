{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.users.tiebe;
  evictCfg = config.tiebe.system.boot.evictDarlings;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./darlings.nix
  ];

  options = {
    tiebe.system.users.tiebe = {
      enable = mkEnableOption "primary user (tiebe)";
    };
  };

  config = mkIf cfg.enable {
    users.users = {
      tiebe = {
        hashedPasswordFile = config.age.secrets.password.path;
        password = "init";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdp0QozaAQ6KdrB3UCUnlVZMJW+0nvncMDgKoZXBkyoffUGKRhSZ2MPOw9AIlhK7YPg2gcNw6KNswKw2Es4ZTn7yxvCDGTZtCUSw3/oelpTYXsH64wJULoWnizsjuyGrCgjH8uwXj0+SQb4N39NMxHa2FI3Z6FogdNmgMY6GGJI5LNezOQwB2b8/U+Lupxk5/RAvCbmwW2gMKwwUJk2H+zqYHFiNbk6YGsSAWMNL3Nj3ygk9pxrxZizMXpRNeufhY/7ewHi5S2JHOpGdT9EowpYVFjn54hv643UbXEIs4f92aba3MMj2GZlgHR3aR+DWTBsPsyjwRh+gqrpUTnPOxAEZP1RPnKFQ8nRbaWcsHTAN5LoUjGc3LDdEuOo8FkWr3X34bSCocZpdwfd0S8h6UQKghiPnSbCjb6tP92m87N/Nz0dWH9y2eyhY6PWfq9/7LkPOCCZIUerKUUhzZY3YfGIu/mbtURTKguysZS8mXVVPJXzJENMNyRqGtZWwGTfKZWBnXyxib+6UjMct2UU0UTZSgp/htgoGqpMngYh/qhpiTn/NGWuleedAe0Lm7V4Q9KLRpV6OFM6bLCb4ODBJ4uEZhU+Wg1eLzYzfk9HTMeYWtNNzsrsiVBn37W+E0BH5fNJLDlFsbmExI1GcI15Rh+IQBAeQxmrXqAoti+n+RnHQ=="
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIle0zbHzFaTojB7DJU5LL76pPSSRY5S+tusC/ZNbi2 tiebe"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCxANoXEguBulOVdL1jCNJYQs/SVUEE1Iq2rokl21lq tiebe"
        ];
        extraGroups = ["wheel" "dialout" "input" ];
      };
    };

    users.defaultUserShell = pkgs.zsh;
    environment.shells = with pkgs; [zsh];
    programs.zsh.enable = true;

    home-manager = {
      extraSpecialArgs = {
        inherit inputs outputs;
        tiebe = config.tiebe;
      };
      sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
      ];
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
      users = {
        tiebe = {
          config,
          pkgs,
          lib,
          ...
        }: {
          programs.home-manager.enable = true;

          home = {
            username = "tiebe";
            # Use evict darlings home directory if enabled, otherwise fall back to /home/tiebe
            # Use mkForce to override the home-manager default which detects from users.users.tiebe.home
            homeDirectory = lib.mkForce (if evictCfg.enable then evictCfg.homeDir else "/home/tiebe");
          };
          
          # XDG configuration for evict darlings
          xdg = mkIf evictCfg.enable {
            enable = true;
            configHome = "${evictCfg.configDir}";
            cacheHome = "${evictCfg.configDir}/cache";
            dataHome = "${evictCfg.configDir}/local/share";
            stateHome = "${evictCfg.configDir}/local/state";
          };
          
          # Move face files to config directory when using evict darlings
          home.file."${if evictCfg.enable then "config/face.jpg" else ".config/face.jpg"}".source = ./profile.jpg;

          home.stateVersion = "23.11";
        };
      };
    };
  };
}
