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
      # to match the SoloCast's fuller frequency response.
      # capture side is passive (stream) so WirePlumber doesn't treat it as a
      # default source candidate; playback side is the virtual source apps use.
      extraConfig.pipewire."20-arctis-eq" = {
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
              # passive=true: this stream won't be selected as default source
              "capture.props" = {
                "node.name" = "effect_input.arctis-eq";
                "node.target" = "alsa_input.usb-SteelSeries_Arctis_Nova_Pro_Wireless-00.mono-fallback";
                "node.passive" = true;
                "audio.position" = ["MONO"];
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
      };
    };
  };
}
