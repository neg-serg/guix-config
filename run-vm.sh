#!/bin/sh
set -e

echo "Building VM script..."
# Build the VM and get the script path
VM_SCRIPT=$(guix system vm system/vm-config.scm)

echo "Starting VM..."
echo "Connect via SSH: ssh -p 2222 neg@localhost"
echo "Password: guix"

# Run the VM with:
# -m 4G: 4GB RAM
# -smp 2: 2 CPU cores
# -enable-kvm: Hardware acceleration (linux only)
# -nic ...: Networking with port forwarding (Host 2222 -> Guest 22)
"$VM_SCRIPT" \
    -m 4G \
    -smp 8 \
    -cpu host \
    -enable-kvm \
    -vga virtio \
    -device virtio-rng-pci \
    -device virtio-balloon-pci \
    -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
    "$@"
