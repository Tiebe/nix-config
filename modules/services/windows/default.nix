{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.tiebe.services.windows;
in {
  imports = [
    ./scopedHooks.nix
    inputs.nixvirt.nixosModules.default
    ./vm.nix
  ];

  options = {
    tiebe.services.windows = {
      enable = mkEnableOption "Windows VM with VFIO passthrough";

      gpuModule = mkOption {
        type = with types; uniq str;
        description = "The GPU module to enable/disable.";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];

    boot.extraModulePackages = with config.boot.kernelPackages; [vendor-reset];
    boot.kernelModules = ["vendor-reset"];

    virtualisation.libvirt = {
      enable = true;
      connections."qemu:///system" = {
        networks = [
          {
            definition = ./net-windows.xml;
            active = true;
          }
        ];
      };
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "windows" ''
        sudo ${pkgs.libvirt}/bin/virsh start ${cfg.domainName}
      '')

      (pkgs.writeShellScriptBin "iommu-pci" ''
        shopt -s nullglob
        for g in $(${pkgs.findutils}/bin/find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
            echo "IOMMU Group ''${g##*/}:"
            for d in $g/devices/*; do
                echo -e "\t$(${pkgs.pciutils}/bin/lspci -nns ''${d##*/})"
            done;
        done;
      '')

      (pkgs.writeShellScriptBin "iommu-usb" ''
        shopt -s nullglob
        for usb_ctrl in /sys/bus/pci/devices/*/usb*; do
          pci_path=''${usb_ctrl%/*}
          iommu_group=$(${pkgs.coreutils}/bin/readlink $pci_path/iommu_group)
          echo "Bus $(cat $usb_ctrl/busnum) --> ''${pci_path##*/} (IOMMU group ''${iommu_group##*/})"
          ${pkgs.usbutils}/bin/lsusb -s ''${usb_ctrl#*/usb}:
          echo
        done
      '')
    ];

    security.sudo.extraRules = [
      {
        users = ["tiebe"];
        commands = [
          {
            command = "${pkgs.libvirt}/bin/virsh start ${cfg.domainName}";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        runAsRoot = false;
        ovmf.enable = true;
      };

      scopedHooks.qemu = {
        windows-start = {
          enable = true;

          scope = {
            objects = [cfg.domainName];
            operations = ["prepare"];
            subOperations = ["begin"];
          };

          script = ''
            ${pkgs.systemd}/bin/systemctl stop display-manager
            sleep 2
            ${pkgs.kmod}/bin/modprobe -r ${cfg.gpuModule}
            sleep 3
          '';
        };
        windows-stop = {
          enable = true;

          scope = {
            objects = [cfg.domainName];
            operations = ["release"];
            subOperations = ["end"];
          };

          script = ''
            sleep 3
            ${pkgs.kmod}/bin/modprobe ${cfg.gpuModule}
            sleep 2
            ${pkgs.systemd}/bin/systemctl start display-manager
          '';
        };
      };
    };

    users.users.tiebe.extraGroups = ["kvm" "input" "libvirtd"];
    programs.virt-manager.enable = true;

    home-manager.users.tiebe = {
      dconf.settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
      };
    };
  };
}
