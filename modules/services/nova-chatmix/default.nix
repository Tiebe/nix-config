{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.services.nova-chatmix;
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.hidapi
  ]);
in {
  imports = [
    ./darlings.nix
  ];

  options = {
    tiebe.services.nova-chatmix = {
      enable = mkEnableOption "SteelSeries Nova Pro Wireless ChatMix service";
    };
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12e0", TAG+="uaccess", ENV{SYSTEMD_USER_WANTS}+="nova-chatmix.service"
    '';

    home-manager.users.tiebe = {
      systemd.user.services.nova-chatmix = {
        Unit = {
          Description = "SteelSeries Nova Pro Wireless ChatMix daemon";
          After = [
            "pipewire.service"
            "wireplumber.service"
          ];
          Wants = [
            "pipewire.service"
            "wireplumber.service"
          ];
        };

        Install = {
          WantedBy = [
            "default.target"
          ];
        };

        Service = {
          ExecStart = "${pythonEnv}/bin/python ${./nova-chatmix.py}";
          Restart = "always";
          RestartSec = 5;
          Environment = [
            "PATH=${lib.makeBinPath [
              pkgs.pipewire
              pkgs.pulseaudio
            ]}"
          ];
        };
      };
    };
  };
}
