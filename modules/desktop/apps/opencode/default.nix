{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.opencode;

  baseOpencodePackage = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default or null;

  opencodePackage =
    if baseOpencodePackage != null then
      baseOpencodePackage.overrideAttrs (oldAttrs: {
        # Workaround for https://github.com/anomalyco/opencode/issues/18447
        postFixup =
          (oldAttrs.postFixup or "")
          + lib.optionalString pkgs.stdenv.isLinux ''
            wrapProgram $out/bin/opencode \
              --prefix LD_LIBRARY_PATH : ${pkgs.stdenv.cc.cc.lib}/lib
          '';
      })
    else
      null;

  desktopPackage =
    let
      desktop = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.desktop or null;
      outputHashes = import ./opencode-hashes.nix;
    in
    if desktop != null then
      (desktop.override { opencode = opencodePackage; }).overrideAttrs (_: {
        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = inputs.opencode + "/packages/desktop/src-tauri/Cargo.lock";
          inherit outputHashes;
        };
      })
    else
      null;
in
{
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.opencode = {
      enable = mkEnableOption "OpenCode";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      #opencodePackage
      desktopPackage
    ];
  };
}
