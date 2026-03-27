{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.boot.evictDarlings;
in {
  options = {
    tiebe.system.boot.evictDarlings = {
      enable = mkEnableOption "Evict your darlings - two-tier home directory structure";

      user = mkOption {
        type = types.str;
        default = "tiebe";
        description = "The username for the evict darlings setup";
      };

      baseDir = mkOption {
        type = types.str;
        default = "/users/${cfg.user}";
        description = "Base directory for the two-tier home structure (contains config/ and home/)";
      };

      configDir = mkOption {
        type = types.str;
        default = "${cfg.baseDir}/config";
        description = "Directory for application configuration files";
      };

      homeDir = mkOption {
        type = types.str;
        default = "${cfg.baseDir}/home";
        description = "Directory for user documents and personal files";
      };
    };
  };

  config = mkIf cfg.enable {
    # Set the user's home to the base directory (services see this as HOME)
    users.users.${cfg.user} = {
      home = cfg.baseDir;
      createHome = true;
    };

    # Create the actual home directory and config directory
    systemd.tmpfiles.settings = {
      "10-evict-darlings-${cfg.user}" = {
        "${cfg.homeDir}" = {
          d = {
            user = cfg.user;
            group = "root";
            mode = "0700";
          };
        };
        "${cfg.configDir}" = {
          d = {
            user = cfg.user;
            group = "root";
            mode = "0700";
          };
        };
      };
    };

    # # Also ensure persist directories exist for evict darlings
    # fileSystems = mkIf config.tiebe.system.boot.darlings.enable {
    #   "/persist${cfg.baseDir}" = {
    #     device = "/persist${cfg.baseDir}";
    #     options = [ "bind" ];
    #     neededForBoot = true;
    #   };
    #   "/persist${cfg.homeDir}" = {
    #     device = "/persist${cfg.homeDir}";
    #     options = [ "bind" ];
    #     neededForBoot = true;
    #   };
    #   "/persist${cfg.configDir}" = {
    #     device = "/persist${cfg.configDir}";
    #     options = [ "bind" ];
    #     neededForBoot = true;
    #   };
    # };
  };
}
