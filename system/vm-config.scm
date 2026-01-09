;; system/vm-config.scm
;; Optimized configuration for QEMU/KVM Virtual Machine

(define-module (system vm-config)
  #:use-module (guix gexp)
  #:use-module (gnu)
  #:use-module (srfi srfi-1)
  #:use-module (nongnu packages linux)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages certs)
  #:use-module (gnu services networking)
  #:use-module (gnu services spice)
  #:use-module (gnu services avahi)
  #:use-module (gnu services ssh)
  #:use-module (gnu services desktop))

(use-service-modules desktop networking ssh xorg base)
(use-package-modules bootloaders certs vim curl version-control package-management shells)

;; Define desktop services with Yandex Mirror and Nonguix
;; We REMOVE NetworkManager to use simple DHCP (dhcp-client-service-type) instead.
;; This avoids conflicts and ensures the network comes up reliably for SSH 
;; without needing a graphical login first.
(define %my-desktop-services
  (modify-services (remove (lambda (service)
                             (member (service-kind service)
                                     (list network-manager-service-type
                                           modem-manager-service-type
                                           usb-modeswitch-service-type)))
                           %desktop-services)
    (guix-service-type config =>
      (guix-configuration
        (inherit config)
        (substitute-urls
         (append (list "https://mirror.yandex.ru/mirrors/guix/"
                       "https://substitutes.nonguix.org")
                 %default-substitute-urls))
        (authorized-keys
         (append (list (plain-file "nonguix.pub"
                                   "(public-key
 (ecc
  (curve Ed25519)
  (q #C126542AB3CD5257162158E2A634123E9C5877740B79463F006A9F88C08A6911#)))"))
                 %default-authorized-guix-keys))))))

(operating-system
  (host-name "guix-vm")
  (timezone "Europe/Moscow")
  (locale "en_US.utf8")

  ;; Standard Linux kernel (from nonguix) instead of linux-libre
  (kernel linux)
  (firmware (list linux-firmware))

  ;; Bootloader configuration
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("/dev/vda"))))

  ;; Filesystem configuration
  (file-systems (append (list (file-system
                                (mount-point "/mnt/host")
                                (device "host-share")
                                (type "9p")
                                (flags '(shared))
                                (options "trans=virtio,version=9p2000.L,cache=loose")
                                (check? #f))
                              (file-system
                                (mount-point "/")
                                (device "/dev/vda1")
                                (type "ext4")))
                        %base-file-systems))

  ;; Users
  ;; Password 'guix' for user 'neg'
  (users (cons (user-account
                (name "neg")
                (group "users")
                (password (crypt "guix" "$6$salt"))
                (supplementary-groups '("wheel" "netdev" "audio" "video"))
                (shell (file-append zsh "/bin/zsh")))
               %base-user-accounts))

  ;; Packages
  (packages (append (list vim
                          git
                          curl
                          nss-certs
                          zsh
                          zsh-autosuggestions
                          zsh-syntax-highlighting)
                    %base-packages))

  ;; System Services
  (services (append (list
                          ;; SSH Service - Critical for remote access
                          (service openssh-service-type
                                   (openssh-configuration
                                     (permit-root-login #t)
                                     (x11-forwarding? #t)))

                          ;; DHCP Client - Simple, robust networking for VM
                          ;; Replaces NetworkManager to guarantee boot-time IP for SSH
                          (service dhcpcd-service-type)

                          ;; Spice Agent - For copy/paste and resize integration in QEMU
                          (service spice-vdagent-service-type)

                          ;; Avahi - Local network service discovery (mDNS)
                          ;; Makes VM accessible as <hostname>.local
                          (service avahi-service-type))

                    ;; Modified desktop services (w/o NetworkManager)
                    %my-desktop-services)))