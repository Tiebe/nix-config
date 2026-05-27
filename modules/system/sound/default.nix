{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.tiebe.system.sound;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.system.sound = {
      enable = mkEnableOption "sound support";
    };
  };

  config = mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;

      # Arctis EQ runs as a separate pipewire filter-chain instance via the
      # built-in filter-chain.service, avoiding WirePlumber default-nodes-api crashes.
      configPackages = [
        (pkgs.writeTextDir "share/pipewire/filter-chain.conf.d/10-arctis-eq.conf"
          (builtins.toJSON {
            "context.modules" = [
              {
                name = "libpipewire-module-filter-chain";
                args = {
                  "node.name" = "arctis-eq";
                  "node.description" = "Arctis Mic (EQ)";
                  "media.name" = "Arctis Mic (EQ)";
                  "audio.channels" = 1;
                  "audio.position" = ["MONO"];
                  "filter.graph" = {
                    nodes = [
                      {
                        type = "builtin";
                        name = "eq";
                        label = "bq_peaking";
                        control = {
                          "Freq" = 3500.0;
                          "Q" = 0.8;
                          "Gain" = 4.0;
                        };
                      }
                      {
                        type = "builtin";
                        name = "hs";
                        label = "bq_highshelf";
                        control = {
                          "Freq" = 6000.0;
                          "Q" = 0.7;
                          "Gain" = 8.0;
                        };
                      }
                    ];
                    links = [
                      {
                        output = "eq:Out";
                        input = "hs:In";
                      }
                    ];
                  };
                  "capture.props" = {
                    "node.name" = "effect_input.arctis-eq";
                    "target.object" = "alsa_input.usb-SteelSeries_Arctis_Nova_Pro_Wireless-00.mono-fallback";
                    "audio.position" = ["MONO"];
                    "stream.dont-remix" = true;
                  };
                  "playback.props" = {
                    "node.name" = "arctis-eq-out";
                    "node.description" = "Arctis Mic (EQ)";
                    "media.class" = "Audio/Source/Virtual";
                    "audio.position" = ["MONO"];
                  };
                };
              }
            ];
          }))
      ];
    };

    # Enable the built-in filter-chain service (runs pipewire -c filter-chain.conf)
    systemd.user.services.filter-chain = {
      wantedBy = ["pipewire.service"];
    };
  };
}
