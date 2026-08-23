{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.services.winapps;
  darlings = config.tiebe.system.boot.darlings;
  winappsPackages = inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system};
  storageVolume =
    if darlings.enable
    then "/persist/var/lib/winapps:/storage:rw"
    else "winapps_data:/storage:rw";
in {
  imports = [
    ./darlings.nix
  ];

  options.tiebe.services.winapps = {
    enable = mkEnableOption "WinApps";
  };

  config = mkIf cfg.enable {
    tiebe.services.docker = {
      enable = true;
      rootless = false;
    };

    nix.settings = {
      substituters = ["https://winapps.cachix.org/"];
      trusted-public-keys = ["winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="];
    };

    environment.systemPackages = [
      winappsPackages.winapps
      winappsPackages.winapps-launcher
      pkgs.freerdp3
    ];

    home-manager.users.tiebe.xdg.configFile."winapps/winapps.conf".text = ''
      RDP_USER="Docker"
      RDP_PASS="WinApps"
      RDP_ASKPASS=""
      RDP_DOMAIN=""
      RDP_IP="127.0.0.1"
      RDP_PORT="3389"
      VM_NAME="RDPWindows"
      WAFLAVOR="docker"
      RDP_SCALE="100"
      REMOVABLE_MEDIA="/run/media"
      RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"
      RDP_FLAGS_NON_WINDOWS=""
      RDP_FLAGS_WINDOWS=""
      DEBUG="true"
      AUTOPAUSE="off"
      AUTOPAUSE_TIME="300"
      FREERDP_COMMAND=""
      PORT_TIMEOUT="5"
      RDP_TIMEOUT="30"
      APP_SCAN_TIMEOUT="60"
      BOOT_TIMEOUT="120"
      HIDEF="on"
    '';

    virtualisation.oci-containers.containers.WinApps = {
      image = "ghcr.io/dockur/windows:latest";
      autoStart = true;
      environment = {
        CPU_CORES = "6";
        DISK_SIZE = "64G";
        HOME = "/home/tiebe";
        PASSWORD = "WinApps";
        RAM_SIZE = "4G";
        USERNAME = "Docker";
        VERSION = "11";
      };
      volumes = [
        storageVolume
        "/home/tiebe:/shared:rw"
        "${inputs.winapps}/oem:/oem:ro"
      ];
      ports = [
        "127.0.0.1:8006:8006/tcp"
        "127.0.0.1:3389:3389/tcp"
        "127.0.0.1:3389:3389/udp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--device=/dev/kvm:/dev/kvm:rwm"
        "--device=/dev/net/tun:/dev/net/tun:rwm"
        "--stop-timeout=120"
      ];
    };

    systemd.services."docker-WinApps".serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
      TimeoutStopSec = "130s";
    };
  };
}
