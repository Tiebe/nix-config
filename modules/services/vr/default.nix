{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.vr;

  amdgpu-kernel-module = pkgs.callPackage ./amdgpu.nix {
    # Make sure the module targets the same kernel as your system is using.
    kernel = config.boot.kernelPackages.kernel;
  };
in {
  options = {
    tiebe.services.vr = {
      enable = mkEnableOption "VR services, like WiVRn and StardustXR";
    };
  };

  config = mkIf cfg.enable {
    programs.alvr = {
      enable = true;
      openFirewall = true;
    };

    boot.extraModulePackages = [
      (amdgpu-kernel-module.overrideAttrs (_: {
        patches = [
          ./amdgpu.patch
        ];
      }))
    ];

    services.avahi.enable = true;
  };
}
