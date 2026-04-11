{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.system.sound.deepFilter;
  dfPlugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
in {
  imports = [./darlings.nix];

  options = {
    tiebe.system.sound.deepFilter = {
      enable = mkEnableOption "DeepFilterNet noise suppression via PipeWire filter-chain";
      attenuationLimit = mkOption {
        type = types.int;
        default = 100;
        description = "Attenuation limit in dB (0 = bypass, 100 = max suppression). 6-12 for subtle, 18-24 for moderate.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.pipewire.extraConfig.pipewire."99-deepfilter-source" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "DeepFilter Noise Canceling Source";
            "media.name" = "DeepFilter Noise Canceling Source";
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "DeepFilter Mono";
                  plugin = dfPlugin;
                  label = "deep_filter_mono";
                  control = {
                    "Attenuation Limit (dB)" = cfg.attenuationLimit;
                  };
                }
              ];
            };
            "audio.rate" = 48000;
            "audio.position" = ["MONO"];
            "capture.props" = {
              "node.passive" = true;
            };
            "playback.props" = {
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };
  };
}
