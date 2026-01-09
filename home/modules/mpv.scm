(define-module (home modules mpv)
  #:use-module (gnu home services)
  #:use-module (gnu packages video)
  #:use-module (guix gexp)
  #:export (mpv-service))

(define mpv-conf-content
  (plain-file "mpv.conf"
"# MPV Configuration for HDR on Hyprland (Wayland)

# Video Output
vo=gpu-next
gpu-api=vulkan
gpu-context=auto

# HDR passthrough/tone-mapping behavior
# Tell Hyprland to handle the colorspace (required for HDR to work properly)
target-colorspace-hint=yes

# Colorspace
# These ensure mpv doesn't try to clamp the gamut prematurely
gamut-clipping=no
tone-mapping=auto

# Performance
hwdec=auto-safe
profile=gpu-hq

# OSD
osd-bar=no
border=no
"))

(define mpv-service
  (simple-service 'user-mpv-config
                  home-files-service-type
                  (list `(".config/mpv/mpv.conf" ,mpv-conf-content))))
