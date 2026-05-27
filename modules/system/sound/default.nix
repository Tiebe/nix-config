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

      # Arctis headset mic EQ: boosts presence (3.5kHz) and high shelf (6kHz+)
      # to match the SoloCast's fuller frequency response
      extraConfig.pipewire."20-arctis-eq" = {
        "context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.name" = "arctis-eq";
              "node.description" = "Arctis EQ";
              "media.name" = "Arctis EQ";
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
                "node.target" = "alsa_input.usb-SteelSeries_Arctis_Nova_Pro_Wireless-00.mono-fallback";
                "audio.position" = "MONO";
              };
              "playback.props" = {
                "media.class" = "Audio/Source/Virtual";
                "node.name" = "arctis-eq-out";
                "node.description" = "Arctis Mic (EQ)";
                "audio.position" = "MONO";
              };
            };
          }
        ];
      };

      # Combined mic: mixes arctis-eq-out and SoloCast into one virtual source
      extraConfig.pipewire-pulse."10-combined-mic" = {
        "pulse.cmd" = [
          {
            cmd = "load-module";
            args = "module-null-sink sink_name=combined-mic sink_properties=device.description=Combined-Microphone rate=48000 channels=1 channel_map=mono";
          }
          {
            cmd = "load-module";
            args = "module-loopback source=arctis-eq-out sink=combined-mic latency_msec=1";
          }
          {
            cmd = "load-module";
            args = "module-loopback source=alsa_input.usb-HP__Inc_HyperX_SoloCast-00.HiFi__Mic__source sink=combined-mic latency_msec=1";
          }
        ];
      };
    };
  };
}
