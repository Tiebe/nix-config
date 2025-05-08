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
  options = {
    tiebe.services.windows = {
      domainName = mkOption {
        type = with types; uniq str;
        description = "The domain name for the virtual machine.";
        default = "windows";
      };

      uuid = mkOption {
        type = with types; uniq str;
        description = "The UUID for the virtual machine.";
      };

      cpu = {
        cores = mkOption {
          type = with types; uniq int;
          description = "The amount of cores.";
        };

        threads = mkOption {
          type = with types; uniq int;
          description = "The amount of threads per core.";
        };
      };

      memory = mkOption {
        type = with types; uniq int;
        description = "The amount of memory, in GiB.";
      };

      diskPath = mkOption {
        type = with types; uniq str;
        description = "The location of the disk image.";
      };

      nvramPath = mkOption {
        type = with types; uniq str;
        description = "The location of the NVRAM data.";
      };

      sysinfo = {
        bios = {
          vendor = mkOption {
            type = types.str;
            description = "BIOS vendor string.";
          };
          version = mkOption {
            type = types.str;
            description = "BIOS version string.";
          };
          date = mkOption {
            type = types.str;
            description = "BIOS release date (MM/DD/YYYY).";
          };
        };

        system = {
          manufacturer = mkOption {
            type = types.str;
            description = "System manufacturer.";
          };
          product = mkOption {
            type = types.str;
            description = "System product/model.";
          };
          version = mkOption {
            type = types.str;
            description = "System version string.";
          };
          serial = mkOption {
            type = types.str;
            description = "System serial number.";
          };
          family = mkOption {
            type = types.str;
            description = "System family.";
          };
        };
      };

      pciDevices = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "A list of PCI devices to passthrough to the guest.";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.libvirt.connections."qemu:///session".domains = [
      {
        active = false;
        definition = pkgs.replaceVars ./windows.xml {
          uuid = cfg.uuid;

          domainName = cfg.domainName;
          memory = cfg.memory;
          vcpu = cfg.cpu.cores * cfg.cpu.threads;
          loaderPath = "${pkgs.qemu}/share/qemu/edk2-x86_64-secure-code.fd";
          nvramTemplate = "${pkgs.qemu}/share/qemu/edk2-i386-vars.fd";
          nvramPath = cfg.nvramPath;

          biosVendor = cfg.sysinfo.bios.vendor;
          biosVersion = cfg.sysinfo.bios.version;
          biosDate = cfg.sysinfo.bios.date;

          systemManufacturer = cfg.sysinfo.system.manufacturer;
          systemProduct = cfg.sysinfo.system.product;
          systemVersion = cfg.sysinfo.system.version;
          systemSerial = cfg.sysinfo.system.serial;
          systemFamily = cfg.sysinfo.system.family;

          cores = cfg.cpu.cores;
          threads = cfg.cpu.threads;

          qemuPath = "${pkgs.qemu}/bin/qemu-system-x86_64";

          diskPath = cfg.diskPath;
          pciDevices = lib.concatStringsSep "\n" (map (pciDevice: ''
              <hostdev mode="subsystem" type="pci" managed="yes">
                <source>
                  <address domain="${pciDevice.source.domain}" bus="${pciDevice.source.bus}" slot="${pciDevice.source.slot}" function="${pciDevice.source.function}"/>
                </source>
              </hostdev>
            '')
            cfg.pciDevices);
        };
      }
    ];
  };
}
