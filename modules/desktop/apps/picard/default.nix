{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.picard;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.picard = {
      enable = mkEnableOption "MusicBrainz Picard, the music tagger and file organiser";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      picard

      # Picard's "Scan" (AcoustID fingerprinting) shells out to fpcalc, which
      # its own closure does not carry; it is picked up from PATH.
      chromaprint
    ];
  };
}
