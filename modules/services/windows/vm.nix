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
        definition = inputs.nixvirt.lib.domain.writeXML {
          name = cfg.domainName;
          uuid = cfg.uuid;
          type = "kvm";

          metadata = with inputs.nixvirt.lib.xml; [
      (elem "libosinfo:libosinfo" [ (attr "xmlns:libosinfo" "http://libosinfo.org/xmlns/libvirt/domain/1.0") ]
        [
          (elem "libosinfo:os" [ (attr "id" "http://microsoft.com/win/11") ] [ ])
        ])
    ];

          memory = {
            count = cfg.memory;
            unit = "GiB";
          };
          currentMemory = {
            count = cfg.memory;
            unit = "GiB";
          };
          vcpu = {
            placement = "static";
            count = cfg.cpu.cores * cfg.cpu.threads;
          };

          os = {
            type = "hvm";
            arch = "x86_64";
            machine = "pc-q35-9.2";
            firmware = "efi";
            loader = {
              path = "${pkgs.qemu}/share/qemu/edk2-x86_64-secure-code.fd";
              readonly = true;
              secure = true;
              type = "pflash";
              format = "raw";
            };
            nvram = {
              template = "${pkgs.qemu}/share/qemu/edk2-i386-vars.fd";
              templateFormat = "raw";
              path = cfg.nvramPath;
              format = "raw";
            };
            boot = [{ dev = "hd"; }];
            smbios.mode = "sysinfo";
          };

          sysinfo = {
            bios = {
              vendor = cfg.sysinfo.bios.vendor;
              version = cfg.sysinfo.bios.version;
              date = cfg.sysinfo.bios.date;
            };
            system = {
              manufacturer = cfg.sysinfo.system.manufacturer;
              product = cfg.sysinfo.system.product;
              version = cfg.sysinfo.system.version;
              serial = cfg.sysinfo.system.serial;
              uuid = cfg.uuid;
              family = cfg.sysinfo.system.family;
            };
          };

          features = {
            acpi = true;
            apic = true;
            hyperv = {
              mode = "passthrough";
              relaxed.state = true;
              vapic.state = true;
              spinlocks = {
                state = true;
                retries = 8191;
              };
              vpindex.state = true;
              runtime.state = true;
              synic.state = true;
              stimer.state = true;
              frequencies.state = true;
              tlbflush.state = true;
              ipi.state = true;
              evmcs.state = true;
              avic.state = true;
              vendorId = {
                state = true;
                value = "0123756792CD";
              };
            };
            kvm.hidden.state = true;
            vmport.state = false;
            smm.state = true;
          };

          cpu = {
            mode = "host-passthrough";
            check = "none";
            migratable = true;
            topology = {
              sockets = 1;
              dies = 1;
              clusters = 1;
              cores = cfg.cpu.cores;
              threads = cfg.cpu.threads;
            };
          };

          clock = {
            offset = "localtime";
            timer = [
              {
                name = "rtc";
                tickpolicy = "catchup";
              }
              {
                name = "pit";
                tickpolicy = "delay";
              }
              {
                name = "hpet";
                present = false;
              }
              {
                name = "hypervclock";
                present = true;
              }
            ];
          };

          onPoweroff = "destroy";
          onReboot = "restart";
          onCrash = "destroy";

          pm = {
            suspendToMem = false;
            suspendToDisk = false;
          };

          emulator = "${pkgs.qemu}/bin/qemu-system-x86_64";

          disks = {
            root = {
              type = "file";
              device = "disk";
              driver = {
                name = "qemu";
                type = "qcow2";
              };
              source = {file = cfg.diskPath;};
              target = {
                dev = "vda";
                bus = "virtio";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x04";
                slot = "0x00";
                function = "0x0";
              };
            };
          };

          interface = {
            type = "network";
            mac = "52:54:00:3a:49:be";
            source = {network = "net-windows";};
            model = "virtio";
          };

          hostDevices = cfg.pciDevices;

          watchdog = {
            model = "itco";
            action = "reset";
          };
          memballoon = {
            model = "virtio";
            address = {
              type = "pci";
              domain = "0x0000";
              bus = "0x05";
              slot = "0x00";
              function = "0x0";
            };
          };
        };
      }
    ];
  };
}
