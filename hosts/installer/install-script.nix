{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  installScript = pkgs.writeShellScriptBin "nix-install-darlings" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    log_info() {
      echo -e "''${BLUE}[INFO]''${NC} $1"
    }

    log_success() {
      echo -e "''${GREEN}[SUCCESS]''${NC} $1"
    }

    log_warn() {
      echo -e "''${YELLOW}[WARN]''${NC} $1"
    }

    log_error() {
      echo -e "''${RED}[ERROR]''${NC} $1"
    }

    # Header
    clear
    echo "═══════════════════════════════════════════════════════════"
    echo "     NixOS Erase-Your-Darlings Installer"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "This installer will:"
    echo "  1. Partition your disk with BTRFS subvolumes"
    echo "  2. Set up ephemeral root (wiped on every boot)"
    echo "  3. Create persistent storage at /persist"
    echo "  4. Install NixOS with your flake configuration"
    echo ""
    echo "⚠️  WARNING: All data on the selected disk will be ERASED!"
    echo ""

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
      log_error "Please run as root (use sudo)"
      exit 1
    fi

    # Check for gum (pretty prompts)
    if command -v gum &> /dev/null; then
      USE_GUM=true
    else
      USE_GUM=false
    fi

    # Select disk
    log_info "Detecting available disks..."
    echo ""

    # Get list of disks
    mapfile -t DISKS < <(lsblk -d -o NAME,SIZE,MODEL -n | grep -E '^[a-z]+')

    if [ ''${#DISKS[@]} -eq 0 ]; then
      log_error "No disks found!"
      exit 1
    fi

    echo "Available disks:"
    for i in "''${!DISKS[@]}"; do
      echo "  [$((i+1))] ''${DISKS[$i]}"
    done
    echo ""

    if [ "$USE_GUM" = true ]; then
      DISK_NAME=$(echo "''${DISKS[@]}" | tr ' ' '\n' | gum choose)
      DISK="/dev/$(echo "$DISK_NAME" | awk '{print $1}')"
    else
      read -p "Select disk number: " DISK_NUM
      DISK="/dev/$(echo "''${DISKS[$((DISK_NUM-1))]}" | awk '{print $1}')"
    fi

    log_info "Selected disk: $DISK"
    echo ""

    # Check if config exists
    if [ ! -d /persist/etc/nixos ]; then
      log_warn "No NixOS configuration found at /persist/etc/nixos"
      echo ""
      echo "You need to clone your nix-config repository first."
      echo "Example:"
      echo "  mkdir -p /persist/etc"
      echo "  git clone https://github.com/yourusername/nix-config /persist/etc/nixos"
      echo ""
      exit 1
    fi

    # Select host
    log_info "Available hosts:"
    HOSTS_DIR="/persist/etc/nixos/hosts"
    mapfile -t HOSTS < <(find "$HOSTS_DIR" -maxdepth 1 -type d -not -name "installer" -not -name "vm" -exec basename {} \; | sort)

    if [ ''${#HOSTS[@]} -eq 0 ]; then
      log_error "No hosts found in $HOSTS_DIR"
      exit 1
    fi

    for i in "''${!HOSTS[@]}"; do
      echo "  [$((i+1))] ''${HOSTS[$i]}"
    done
    echo ""

    if [ "$USE_GUM" = true ]; then
      TARGET_HOST=$(echo "''${HOSTS[@]}" | tr ' ' '\n' | gum choose)
    else
      read -p "Select host number: " HOST_NUM
      TARGET_HOST="''${HOSTS[$((HOST_NUM-1))]}"
    fi

    log_info "Target host: $TARGET_HOST"
    echo ""

    # Final confirmation
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    log_warn "FINAL CONFIRMATION"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "  Disk:        $DISK"
    echo "  Host:        $TARGET_HOST"
    echo "  Config:      /persist/etc/nixos"
    echo "  BTRFS setup: root, nix, persist, home, log subvolumes"
    echo "  Ephemeral:   Yes (root wiped on boot)"
    echo ""
    echo "This will COMPLETELY ERASE the disk!"
    echo ""

    if [ "$USE_GUM" = true ]; then
      gum confirm --default=false --affirmative="Yes, erase disk" --negative="Cancel" "Are you sure?"
    else
      read -p "Type 'yes' to continue: " CONFIRM
      if [[ "$CONFIRM" != "yes" ]]; then
        log_info "Aborted."
        exit 1
      fi
    fi

    # Update disko device in config
    log_info "Updating disko configuration..."
    sed -i "s|device = lib.mkDefault \"/dev/nvme0n1\";|device = lib.mkDefault \"$DISK\";|" /persist/etc/nixos/hosts/installer/disko.nix

    # Run disko
    log_info "Partitioning disk with disko..."
    nix run github:nix-community/disko/latest -- \
      --mode zap_create_mount \
      /persist/etc/nixos/hosts/installer/disko.nix

    log_success "Disk partitioning complete!"
    echo ""

    # Create directory structure on /persist
    log_info "Setting up persistent directory structure..."

    # Core system directories
    mkdir -p /mnt/persist/etc/nixos
    mkdir -p /mnt/persist/etc/ssh
    mkdir -p /mnt/persist/etc/openvpn
    mkdir -p /mnt/persist/var/lib/systemd/backlight
    mkdir -p /mnt/persist/var/lib/bluetooth
    mkdir -p /mnt/persist/var/lib/fprint
    mkdir -p /mnt/persist/var/lib/ratbagd
    mkdir -p /mnt/persist/var/lib/monado
    mkdir -p /mnt/persist/var/lib/cups
    mkdir -p /mnt/persist/var/spool/cups
    mkdir -p /mnt/persist/var/lib/containers
    mkdir -p /mnt/persist/windows

    # User directories (standard layout)
    mkdir -p /mnt/persist/home/tiebe/.config
    mkdir -p /mnt/persist/home/tiebe/.local/share
    mkdir -p /mnt/persist/home/tiebe/.cache
    mkdir -p /mnt/persist/home/tiebe/.var/app
    mkdir -p /mnt/persist/home/tiebe/.mozilla
    mkdir -p /mnt/persist/home/tiebe/.thunderbird
    mkdir -p /mnt/persist/home/tiebe/.gnupg

    # User directories (evict-darlings layout)
    mkdir -p /mnt/persist/users/tiebe/config
    mkdir -p /mnt/persist/users/tiebe/home

    # Copy configuration to /persist
    log_info "Copying NixOS configuration to /persist..."
    cp -r /persist/etc/nixos/* /mnt/persist/etc/nixos/

    # Copy SSH keys if they exist
    if [ -d /persist/etc/ssh ]; then
      log_info "Copying SSH host keys..."
      cp -r /persist/etc/ssh/* /mnt/persist/etc/ssh/
    fi

    # Generate machine-id
    log_info "Generating machine-id..."
    systemd-machine-id-setup --root=/mnt/persist

    # Generate hardware configuration
    log_info "Generating hardware configuration..."
    mkdir -p "/mnt/persist/etc/nixos/hosts/$TARGET_HOST"
    nixos-generate-config --root /mnt --show-hardware-config \
      > "/mnt/persist/etc/nixos/hosts/$TARGET_HOST/hardware-configuration.nix"

    log_success "Hardware configuration saved!"
    echo ""

    # Install NixOS
    log_info "Installing NixOS (this may take a while)..."
    echo ""

    nixos-install \
      --flake "/mnt/persist/etc/nixos#$TARGET_HOST" \
      --no-root-passwd

    log_success "NixOS installation complete!"
    echo ""

    # Final instructions
    echo "═══════════════════════════════════════════════════════════"
    echo "              Installation Complete!"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    log_success "Your erase-your-darlings NixOS system is ready!"
    echo ""
    echo "Next steps:"
    echo "  1. Set root password: passwd"
    echo "  2. Exit chroot: exit"
    echo "  3. Unmount: umount -R /mnt"
    echo "  4. Reboot: reboot"
    echo ""
    echo "After reboot, your system will:"
    echo "  - Have an ephemeral root (wiped on every boot)"
    echo "  - Preserve data in /persist"
    echo "  - Rollback to a clean state automatically"
    echo ""
    log_info "Welcome to your new NixOS system!"
  '';
in {
  config = lib.mkIf config.tiebe.installer.enable {
    environment.systemPackages = [
      installScript
      pkgs.gum
    ];

    # Auto-start installer on tty1 (optional, can be disabled)
    systemd.services.installer-autostart = {
      description = "Auto-start NixOS installer on tty1";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "getty@tty1.service"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "autostart" "
          sleep 2
          clear
          echo 'Starting NixOS Erase-Your-Darlings Installer...'
          echo ''
          echo 'Run: nix-install-darlings'
          echo ''
          exec ${pkgs.bash}/bin/bash -l
        "}";
        StandardInput = "tty";
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
    };
  };
}
