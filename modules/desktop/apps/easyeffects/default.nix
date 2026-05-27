{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.easyeffects;

  # Arctis EQ preset: boosts presence (3.5kHz) and high shelf (6kHz+)
  # to match the SoloCast's fuller frequency response
  arctisEqPreset = {
    input = {
      blocklist = [];
      plugins_order = [
        "equalizer#0"
      ];
      "equalizer#0" = {
        bypass = false;
        input-gain = 0.0;
        output-gain = 0.0;
        mode = "IIR";
        num-bands = 2;
        split-channels = false;
        "band0" = {
          frequency = 3500.0;
          gain = 4.0;
          mode = "APO (DR)";
          mute = false;
          q = 0.8;
          slope = "x1";
          solo = false;
          type = "Bell";
        };
        "band1" = {
          frequency = 6000.0;
          gain = 8.0;
          mode = "APO (DR)";
          mute = false;
          q = 0.7;
          slope = "x1";
          solo = false;
          type = "Hi-shelf";
        };
      };
    };
  };
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.easyeffects = {
      enable = mkEnableOption "EasyEffects audio processing with Arctis mic EQ";
    };
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;

    home-manager.users.tiebe = {
      services.easyeffects = {
        enable = true;
        preset = "arctis-eq";
        extraPresets = {
          "arctis-eq" = arctisEqPreset;
        };
      };
    };

    # Combined mic: mixes EasyEffects-processed Arctis (easyeffects_source)
    # and SoloCast into one virtual source. EasyEffects must be running first.
    services.pipewire.extraConfig.pipewire-pulse."10-combined-mic" = {
      "pulse.cmd" = [
        {
          cmd = "load-module";
          args = "module-null-sink sink_name=combined-mic sink_properties=device.description=Combined-Microphone rate=48000 channels=1 channel_map=mono";
        }
        {
          cmd = "load-module";
          args = "module-loopback source=easyeffects_source sink=combined-mic latency_msec=1";
        }
        {
          cmd = "load-module";
          args = "module-loopback source=alsa_input.usb-HP__Inc_HyperX_SoloCast-00.HiFi__Mic__source sink=combined-mic latency_msec=1";
        }
      ];
    };
  };
}
