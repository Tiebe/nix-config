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
  cfg = config.tiebe.system.sound.arctisEq;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.system.sound.arctisEq = {
      enable = mkEnableOption ''
        Arctis mic EQ via a PipeWire filter-chain convolver. Applies a measured
        impulse response (arctis-match.irs) that shapes the SteelSeries Arctis
        boom mic to match the HyperX SoloCast's tonal balance, and exposes the
        result as a virtual "Arctis EQ Mic" source'';
      micNode = mkOption {
        type = types.str;
        default = "alsa_input.usb-SteelSeries_Arctis_Nova_Pro_Wireless-00.mono-fallback";
        description = "PipeWire node.name of the hardware Arctis mic to capture from.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.pipewire.extraConfig.pipewire."99-arctis-eq-source" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Arctis EQ Mic";
            "media.name" = "Arctis EQ Mic";
            "filter.graph" = {
              nodes = [
                {
                  type = "builtin";
                  name = "conv";
                  label = "convolver";
                  config = {
                    # Minimum-phase IR (near-zero latency). channel 0 = mono kernel.
                    filename = "${./arctis-match.irs}";
                    channel = 0;
                    # -6 dB headroom so the low-mid boost doesn't clip loud speech.
                    gain = 0.5;
                  };
                }
              ];
            };
            "audio.rate" = 48000;
            "audio.position" = ["MONO"];
            "capture.props" = {
              "node.name" = "capture.arctis_eq";
              "node.passive" = true;
              # Source from the Arctis mic specifically, not the default device.
              "target.object" = cfg.micNode;
            };
            "playback.props" = {
              "node.name" = "arctis_eq_source";
              "node.description" = "Arctis EQ Mic";
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };
  };
}
