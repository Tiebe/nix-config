#!/usr/bin/env bash
# Test script for erase darlings VM

set -e

VM_NAME="victoria-test-vm"
DISK_SIZE="50G"
VM_DIR="${HOME}/.local/share/victoria-test-vm"
DISK_FILE="${VM_DIR}/disk.raw"

create_disk() {
    echo "Creating VM directory..."
    mkdir -p "${VM_DIR}"
    
    if [ -f "${DISK_FILE}" ]; then
        echo "Disk already exists at ${DISK_FILE}"
        echo "Run './test-vm.sh clean' first to recreate"
        return 1
    fi
    
    echo "Creating raw disk image (${DISK_SIZE})..."
    # Use fallocate for fast sparse allocation that actually reports the size to btrfs
    fallocate -l "${DISK_SIZE}" "${DISK_FILE}" 2>/dev/null || \
        (echo "fallocate failed, using dd (slower)..." && \
         dd if=/dev/zero of="${DISK_FILE}" bs=1M count=1 seek=51199)
    
    echo "Setting up disk with btrfs subvolumes..."
    
    # Create a temporary script to format the disk
    cat > /tmp/format-disk.nix << 'EOF'
let
  pkgs = import <nixpkgs> {};
in
pkgs.writeShellScriptBin "format-disk" ''
  set -e
  DISK="$1"
  
  echo "Formatting $DISK as btrfs..."
  ${pkgs.btrfs-progs}/bin/mkfs.btrfs -f "$DISK"
  
  echo "Creating subvolumes..."
  MOUNT=$(mktemp -d)
  mount "$DISK" "$MOUNT"
  
  ${pkgs.btrfs-progs}/bin/btrfs subvolume create "$MOUNT/root"
  ${pkgs.btrfs-progs}/bin/btrfs subvolume create "$MOUNT/home"
  ${pkgs.btrfs-progs}/bin/btrfs subvolume create "$MOUNT/persist"
  ${pkgs.btrfs-progs}/bin/btrfs subvolume create "$MOUNT/nix"
  ${pkgs.btrfs-progs}/bin/btrfs subvolume create "$MOUNT/log"
  
  umount "$MOUNT"
  rmdir "$MOUNT"
  
  echo "Disk formatted successfully!"
''
EOF

    nix-build /tmp/format-disk.nix -o /tmp/format-disk-result
    sudo /tmp/format-disk-result/bin/format-disk "${DISK_FILE}"
    
    echo "Disk created at: ${DISK_FILE}"
}

build_vm() {
    echo "Building VM configuration..."
    cd /home/tiebe/nix-config
    nix build .#nixosConfigurations.victoria-test-vm.config.system.build.vm
    echo "VM built successfully!"
}

run_vm() {
    if [ ! -f "${DISK_FILE}" ]; then
        echo "Disk not found. Creating..."
        create_disk
    fi
    
    echo "Starting VM..."
    cd /home/tiebe/nix-config
    
    # Run the VM with the persistent disk
    nix run .#nixosConfigurations.victoria-test-vm.config.system.build.vm -- \
        -drive file="${DISK_FILE}",format=raw,if=virtio \
        -m 8192 \
        -smp 4 \
        -cpu host \
        -enable-kvm \
        -netdev user,id=net0,hostfwd=tcp::2222-:22 \
        -device virtio-net-pci,netdev=net0 \
        "$@"
}

clean_disk() {
    echo "Removing VM disk..."
    rm -f "${VM_DIR}"/*.{raw,qcow2}
    echo "Disk removed. Next run will create a fresh disk."
}

case "${1:-run}" in
    create)
        create_disk
        ;;
    build)
        build_vm
        ;;
    run)
        run_vm
        ;;
    clean)
        clean_disk
        ;;
    *)
        echo "Usage: $0 {create|build|run|clean}"
        echo ""
        echo "Commands:"
        echo "  create  - Create the VM disk with btrfs subvolumes"
        echo "  build   - Build the VM configuration"
        echo "  run     - Run the VM (creates disk if needed)"
        echo "  clean   - Remove the VM disk to start fresh"
        echo ""
        echo "Examples:"
        echo "  $0 create    # First time setup"
        echo "  $0 run       # Start the VM"
        echo "  $0 clean     # Reset the disk"
        exit 1
        ;;
esac