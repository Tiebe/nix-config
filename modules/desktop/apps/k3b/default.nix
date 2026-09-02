{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.desktop.apps.k3b;
in {
  imports = [./darlings.nix];

  options = {
    tiebe.desktop.apps.k3b = {
      enable = mkEnableOption "k3b, the KDE optical disc burning application";
    };
  };

  config = mkIf cfg.enable {
    # Installs kdePackages.k3b, cdrdao, cdrtools and dvdplusrwtools, plus the
    # setuid /run/wrappers/bin/{cdrdao,cdrecord} wrappers k3b needs for burning.
    # /run/wrappers/bin precedes the system profile in PATH, so k3b's external
    # program search picks up the wrappers without manual configuration.
    programs.k3b.enable = true;

    # k3b enumerates drives through Solid, whose only OpticalDrive backend is
    # UDisks2. Without this service k3b reports "no optical drive found" even
    # though /dev/sr0 exists and is accessible.
    services.udisks2.enable = true;

    # cdrtools' SCSI transport talks to the drive through /dev/sg*, which only
    # exists once the sg module is loaded.
    boot.kernelModules = ["sg"];

    # Required by the setuid wrappers above (owned root:cdrom, mode u+wrx,g+x).
    # Device access itself already comes from the udev uaccess ACL on /dev/sr0.
    users.users.tiebe.extraGroups = ["cdrom"];
  };
}
