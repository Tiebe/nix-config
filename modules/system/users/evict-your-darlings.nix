{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.users.tiebe.evict-your-darlings;
in {
  options = {
    tiebe.system.users.tiebe.evict-your-darlings = {
      enable = mkEnableOption "evict your darlings. https://r.je/evict-your-darlings";
    };
  };

  config = mkIf cfg.enable {
    users.users.tiebe = {
      home = "/users/tiebe";
      createHome = true;
    };

    systemd.tmpfiles.settings = {
      "10-create-home" = {
        "/users/tiebe/home" = {
          d = {
            group = "root";
            mode = "0700";
            user = "tiebe";
          };
        };
      };
    };

    home-manager.users.tiebe = {
      xdg = {
        enable = true;
        configHome = "/users/tiebe/config";
        cacheHome = "/users/tiebe/config/cache";
        dataHome = "/users/tiebe/config/local/share";
        stateHome = "/users/tiebe/config/local/state";
      };
    };

    home-manager.users.tiebe = {
      home.sessionVariables = {
        # GIT_SSH_COMMAND = ""
      };
    };

    environment.etc."gdm3/PostLogin/Default".text = "export HOME=/users/tiebe/home";
  };
}
