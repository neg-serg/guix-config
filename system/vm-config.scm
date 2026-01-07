;; system/vm-config.scm
;; Optimized configuration for QEMU/KVM Virtual Machine

(define-module (system vm-config)
  #:use-module (guix gexp)
  #:use-module (gnu)
  #:use-module (gnu services spice))

(use-service-modules desktop networking ssh xorg)
(use-package-modules bootloaders certs vim curl version-control package-management)

(operating-system
  (host-name "guix-vm")
  (timezone "Europe/Moscow")
  (locale "en_US.utf8")

  ;; Use the standard linux-libre kernel.
  ;; For QEMU, we don't strictly need 'linux' (nonguix) unless testing specific proprietary drivers.
  ;; VirtIO drivers are fully free and included in linux-libre.
  (kernel linux-libre)

  ;; Bootloader configuration
  ;; We assume the VM disk is /dev/vda
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("/dev/vda"))))

  ;; Filesystem configuration
  ;; Basic partition layout: /dev/vda1 -> /
  (file-systems (cons (file-system
                        (mount-point "/")
                        (device "/dev/vda1")
                        (type "ext4"))
                      %base-file-systems))

  ;; Users
  ;; Default password for 'neg' is 'guix' (generated via `mkpasswd -m sha-512`)
  (users (cons (user-account
                (name "neg")
                (group "users")
                (password (crypt "guix" "$6$salt"))
                (supplementary-groups '("wheel" "netdev" "audio" "video")))
               %base-user-accounts))

  ;; Packages to install system-wide
  (packages (append (list vim
                          git
                          curl
                          nss-certs ;; SSL certificates for HTTPS
                          )
                    %base-packages))

  ;; System Services
  (services (append (list 
                          ;; SSH access
                          (service openssh-service-type)
                          
                          ;; Networking via DHCP
                          (service dhcp-client-service-type)

                          ;; Spice Agent: Critical for Copy/Paste and auto-resizing in QEMU
                          (service spice-vdagent-service-type))
                    
                    ;; Standard desktop services (includes graphical interface, login manager, etc.)
                    %desktop-services)))
