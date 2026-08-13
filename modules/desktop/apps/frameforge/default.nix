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
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.frameforge = {
      enable = mkEnableOption "FrameForge Warframe companion (inventory, market, relic overlay)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [(pkgs.callPackage ./package.nix {})];

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
