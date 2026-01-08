# Guix System Configuration (QEMU VM)

This repository contains a declarative configuration for a Guix System VM, optimized for QEMU/KVM and performance in regions with slow access to standard GNU mirrors (using Codeberg and Yandex Mirror).

## Quick Start (Inside VM)

### 1. Authorize Yandex Mirror (Critical for Speed)
To download binaries from Yandex instead of compiling everything, you must authorize their signing key. Run this command inside the VM:

```bash
wget -O - https://mirror.yandex.ru/mirrors/guix/signing-key.pub | sudo guix archive --authorize
```

### 2. Pull with Optimized Channels
This will update Guix using the faster Codeberg mirror defined in `channels.scm`.

```bash
guix pull --channels=channels.scm
```
*(Note: The first pull might take some time as it compiles package definitions)*

### 3. Apply System Configuration
Reconfigure the system to apply all settings (including the Yandex mirror for future updates).

```bash
sudo guix system reconfigure -L . system/vm-config.scm
```

### 4. Apply User Configuration (Guix Home)
The user configuration (dotfiles, shell, git) is managed via **Guix Home**.
Since the current directory is mounted at `/mnt/host` inside the VM (when using `run-vm.sh`), you can apply it directly:

```bash
guix home reconfigure /mnt/host/home/home-config.scm
```

This will:
- Install your CLI packages (zsh, git, neovim, etc.)
- Configure Zsh aliases and plugins
- Setup Git user and config

## Features

- **Mirrors:** Codeberg (Git) + Yandex (Binaries) for max speed.
- **Kernel:** `linux-libre` (default) + `nonguix` channel ready for full `linux` if needed.
- **Services:**
  - SSH enabled
  - SPICE agent (clipboard sharing with host)
  - DHCP networking
- **CI:** GitHub Actions workflow checks configuration validity on every push.
