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
    # NOTE: this must NOT use `services.udev.extraRules`, which is always
    # written to /etc/udev/rules.d/99-local.rules and is therefore read
    # and applied *after* all other rules (including systemd's own
    # 73-seat-late.rules). Since systemd 261, ACLs for TAG+="uaccess"
    # devices are only applied by the `uaccess` builtin invoked from
    # 73-seat-late.rules, and that rule only sees tags set by rules
    # processed *before* it in file-sort order. A 99-prefixed rule
    # setting TAG+="uaccess" is therefore too late: the tag ends up on
    # the device, but the ACL-granting builtin never runs, so the
    # regular user is left without read/write access to the headset's
    # USB device node. Ship a dedicated 70-prefixed rule file instead so
    # it is processed before 73-seat-late.rules.
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "nova-chatmix-udev-rules";
        destination = "/etc/udev/rules.d/70-nova-chatmix.rules";
        text = ''
          SUBSYSTEM=="usb", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12e0", TAG+="uaccess", ENV{SYSTEMD_USER_WANTS}+="nova-chatmix.service"
        '';
      })
    ];

    # Prevent WirePlumber from moving existing streams to a new default sink.
    # Without this, changing the default to input.NovaGame causes EasyEffects'
    # output to follow, creating a feedback loop with the Nova loopback.
    services.pipewire.wireplumber.extraConfig."99-nova-chatmix" = {
      "wireplumber.settings" = {
        "linking.follow-default-target" = false;
      };
    };

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
              pkgs.busybox
            ]}"
          ];
        };
      };
    };
  };
}
