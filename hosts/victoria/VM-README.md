# Erase Your Darlings - Test VM

This directory contains a VM configuration for testing the erase darlings setup safely.

## Quick Start

```bash
# Build and run the test VM
./test-vm.sh run
```

This will:
1. Create a 50GB virtual disk with btrfs subvolumes
2. Build the NixOS configuration with erase darlings enabled
3. Launch a QEMU VM for testing

## Testing Persistence

Once the VM boots:

```bash
# Test 1: Verify /persist exists
ls -la /persist

# Test 2: Create test data that should persist
echo "survived reboot" > /persist/test.txt

# Test 3: Check Bluetooth persistence (pair a device)
bluetoothctl
# [pair device, trust, connect]
# exit

# Test 4: Check zsh history
echo "test command 123" 
# Then check: cat ~/.zsh_history

# Reboot and verify data persists
reboot
```

After reboot:
```bash
# Verify test file survived
cat /persist/test.txt  # Should show "survived reboot"

# Verify Bluetooth pairings
bluetoothctl
device list  # Should show paired device

# Verify zsh history
cat ~/.zsh_history  # Should show "test command 123"
```

## Available Commands

```bash
./test-vm.sh create   # Create the VM disk (first time only)
./test-vm.sh build    # Build VM configuration
./test-vm.sh run      # Run the VM (creates disk if needed)
./test-vm.sh clean    # Remove disk to start fresh
```

## VM Details

- **Hostname**: victoria-test-vm
- **RAM**: 8GB
- **CPUs**: 4 cores
- **Disk**: 50GB qcow2 with btrfs subvolumes
- **SSH**: Available on port 2222 (host: `ssh -p 2222 tiebe@localhost`)
- **Auto-login**: Enabled for user `tiebe`

## Troubleshooting

**VM won't start**: Make sure KVM is enabled
```bash
lsmod | grep kvm  # Should show kvm and kvm_amd/intel
```

**Disk issues**: Reset the disk
```bash
./test-vm.sh clean
./test-vm.sh run
```

**Slow performance**: The VM runs with software rendering by default. For GPU passthrough, add GPU flags to the QEMU command.