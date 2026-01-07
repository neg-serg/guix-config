;; system/vm-config.scm
;; Optimized configuration for QEMU/KVM Virtual Machine

(define-module (system vm-config)
  #:use-module (guix gexp)
  #:use-module (gnu)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages certs)
  #:use-module (gnu services networking)
  #:use-module (gnu services spice)
  #:use-module (gnu services ssh)
  #:use-module (gnu services desktop))

(use-service-modules desktop networking ssh xorg base)
(use-package-modules bootloaders certs vim curl version-control package-management)

;; Define desktop services with Yandex Mirror
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
         (append (list "https://mirror.yandex.ru/mirrors/guix/")
                 %default-substitute-urls))))))

(operating-system
  (host-name "guix-vm")
  (timezone "Europe/Moscow")
  (locale "en_US.utf8")

  ;; Linux-libre kernel (standard for Guix)
  (kernel linux-libre)

  ;; Bootloader configuration
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("/dev/vda"))))

  ;; Filesystem configuration
  (file-systems (cons (file-system
                        (mount-point "/")
                        (device "/dev/vda1")
                        (type "ext4"))
                      %base-file-systems))

  ;; Users
  ;; Password 'guix' for user 'neg'
  (users (cons (user-account
                (name "neg")
                (group "users")
                (password (crypt "guix" "$6$salt"))
                (supplementary-groups '("wheel" "netdev" "audio" "video")))
               %base-user-accounts))

  ;; Packages
  (packages (append (list vim
                          git
                          curl
                          nss-certs)
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
                          (service dhcp-client-service-type)

                          ;; Spice Agent - For copy/paste and resize integration in QEMU
                          (service spice-vdagent-service-type))

                    ;; Modified desktop services (w/o NetworkManager)
                    %my-desktop-services)))