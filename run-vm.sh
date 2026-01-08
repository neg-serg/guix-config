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
# -smp 8: 8 CPU cores
# -enable-kvm: Hardware acceleration (linux only)
# -nic ...: Networking with port forwarding (Host 2222 -> Guest 22)
# -virtfs ...: Share current directory with VM (mount at /mnt/host)
"$VM_SCRIPT" \
    -m 4G \
    -smp 8 \
    -cpu host \
    -enable-kvm \
    -vga virtio \
    -device virtio-rng-pci \
    -device virtio-balloon-pci \
    -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
    -virtfs local,path=$(pwd),mount_tag=host-share,security_model=none,id=host-share \
    "$@"
