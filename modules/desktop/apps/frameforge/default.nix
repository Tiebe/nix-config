{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tiebe.desktop.apps.frameforge;

  frameforgePackage = pkgs.callPackage ./package.nix {};
  profitTakerAnalyticsPackage = pkgs.callPackage ./profit-taker-analytics.nix {};
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.frameforge = {
      enable = mkEnableOption "FrameForge Warframe companion (inventory, market, relic overlay)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      frameforgePackage
      profitTakerAnalyticsPackage
    ];

    # Register the pta:// URL scheme used by Discord OAuth redirects.
    xdg.mime.defaultApplications = {
      "x-scheme-handler/pta" = "pta-protocol.desktop";
    };

    environment.etc."xdg/applications/pta-protocol.desktop".source = "${profitTakerAnalyticsPackage}/share/applications/pta-protocol.desktop";

    # FrameForge's memory scanner reads Warframe's inventory blob out of
    # /proc/<pid>/mem via ReadProcessMemory-equivalent ptrace access. Warframe
    # runs under Steam Proton as an unrelated process (not a child of
    # FrameForge), so the Yama LSM's default ptrace_scope of 1 (restricted:
    # attach only to descendants) blocks the scan outright. Scope 0 restores
    # classic same-uid ptrace permissions, which is what upstream's own build
    # notes call out as a requirement.
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;
  };
}
