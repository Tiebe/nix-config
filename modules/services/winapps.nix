{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [./docker.nix];

  nix.settings = {
    substituters = ["https://winapps.cachix.org/"];
    trusted-public-keys = ["winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="];
  };

  environment.systemPackages = with pkgs; [
    inputs.winapps.packages.x86_64-linux.winapps
    inputs.winapps.packages.x86_64-linux.winapps-launcher
    freerdp3
    libnotify
    dialog
  ];

  home-manager.users.tiebe = {
    xdg.configFile."winapps/winapps.conf".text = lib.generators.toINIWithGlobalSection {} {
      globalSection = {
        RDP_USER = "Docker";
        RDP_PASS = "WinApps";
        RDP_DOMAIN = "";

        RDP_IP = "127.0.0.1";
        WAFLAVOR = "docker";
        RDP_SCALE = "100";

        RDP_FLAGS = "\"/cert:tofu /sound /microphone\"";
        MULTIMON = "false";
        DEBUG = "true";

        AUTOPAUSE = "on";
        AUTOPAUSE_TIME = "300";
        FREERDP_COMMAND = "";
      };
      sections = {};
    };
  };

  virtualisation.oci-containers.containers."WinApps" = {
    image = "ghcr.io/dockur/windows:latest";
    environment = {
      "CPU_CORES" = "6";
      "DISK_SIZE" = "32G";
      "HOME" = "/home/tiebe";
      "RAM_SIZE" = "4G";
      "VERSION" = "tiny11";
    };
    volumes = [
      "/home/tiebe:/shared:rw"
      "/home/tiebe/Downloads/oem:/oem:rw"
      "winapps_data:/storage:rw"
    ];
    ports = [
      "8006:8006/tcp"
      "3389:3389/tcp"
      "3389:3389/udp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/kvm:/dev/kvm:rwm"
      "--network-alias=windows"
      "--network=winapps_default"
      "--privileged"
    ];
  };
  systemd.services."docker-WinApps" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-winapps_default.service"
      "docker-volume-winapps_data.service"
    ];
    requires = [
      "docker-network-winapps_default.service"
      "docker-volume-winapps_data.service"
    ];
    partOf = [
      "docker-compose-winapps-root.target"
    ];
    wantedBy = [
      "docker-compose-winapps-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-winapps_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f winapps_default";
    };
    script = ''
      docker network inspect winapps_default || docker network create winapps_default
    '';
    partOf = ["docker-compose-winapps-root.target"];
    wantedBy = ["docker-compose-winapps-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-winapps_data" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect winapps_data || docker volume create winapps_data
    '';
    partOf = ["docker-compose-winapps-root.target"];
    wantedBy = ["docker-compose-winapps-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-winapps-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    after = ["graphical.target"];
  };
}
