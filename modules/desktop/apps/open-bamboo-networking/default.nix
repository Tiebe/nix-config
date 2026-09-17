{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.open-bamboo-networking;
  bambuStudioCfg = config.tiebe.desktop.apps.bambu-studio;
  orcaSlicerCfg = config.tiebe.desktop.apps.orcaslicer;
  package = pkgs.callPackage ./package.nix {};

  # Drives the upstream interactive installer non-interactively: line 1
  # selects the slicer (1 = Bambu Studio, 2 = Orca Slicer), line 2 answers
  # the "multiple installations found" prompt (picks the first/non-beta,
  # non-Flatpak entry; ignored when only one candidate exists), line 3
  # confirms the "Proceed?" prompt. Idempotent — the upstream script only
  # rewrites files that actually changed. Silently skipped when the
  # slicer's config directory does not exist yet (i.e. it has never been
  # launched), since the installer requires it and would otherwise abort.
  installFor = choice: configDirName: ''
    if [ -d "$HOME/.config/${configDirName}" ]; then
      printf '${choice}\n1\ny\n' | ${package}/bin/open-bamboo-networking-install >/dev/null 2>&1 || true
    fi
  '';
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.open-bamboo-networking = {
      enable = mkEnableOption "Open Bamboo Networking (open-source bambu_networking plugin replacement)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [package];

    home-manager.users.tiebe = {lib, ...}: {
      # Re-run on every activation so plugin updates and slicer-conf drift
      # (e.g. after an OrcaSlicer/BambuStudio version bump changes the
      # detected ABI) get re-applied automatically.
      home.activation.installOpenBambooNetworking = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -z "''${DRY_RUN_CMD:-}" ]; then
          ${lib.optionalString bambuStudioCfg.enable (installFor "1" "BambuStudio")}
          ${lib.optionalString orcaSlicerCfg.enable (installFor "2" "OrcaSlicer")}
        fi
      '';
    };
  };
}
