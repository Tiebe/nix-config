{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.vr;
in {
  options = {
    tiebe.services.vr = {
      enable = mkEnableOption "VR services, like WiVRn and StardustXR";
    };
  };

  config = mkIf cfg.enable {
    programs.alvr = {
      enable = true;
      openFirewall = true;
    };
    
    services.wivrn = {
      enable = false;
      openFirewall = true;

      # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
      # will automatically read this and work with WiVRn (Note: This does not currently
      # apply for games run in Valve's Proton)
      defaultRuntime = true;

      # Run WiVRn as a systemd service on startup
      autoStart = true;

      # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
      config = {
        enable = true;
        json = {
          # 1.0x foveation scaling
          scale = 1.0;
          # 100 Mb/s
          bitrate = 100000000;
          encoders = [
            {
              encoder = "vaapi";
              codec = "h265";
              # 1.0 x 1.0 scaling
              width = 1.0;
              height = 1.0;
              offset_x = 0.0;
              offset_y = 0.0;
            }
          ];
        };
      };
    };

    services.avahi.enable = true;

    environment.systemPackages = with pkgs; [
      stardust-xr-server
      stardust-xr-flatland
      stardust-xr-magnetar
      stardust-xr-phobetor
      stardust-xr-gravity
      stardust-xr-protostar
      stardust-xr-sphereland
      stardust-xr-atmosphere
    ];
  };
}
