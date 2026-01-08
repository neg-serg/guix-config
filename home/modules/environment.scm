(define-module (home modules environment)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:export (environment-service))

(define environment-vars
  '(;; XDG Directories (Guix sets some default, but ensuring parity)
    ("XDG_CACHE_HOME" . "$HOME/.cache")
    ("XDG_CONFIG_HOME" . "$HOME/.config")
    ("XDG_DATA_HOME" . "$HOME/.local/share")
    ("XDG_STATE_HOME" . "$HOME/.local/state")
    ("XDG_DESKTOP_DIR" . "$HOME/.local/desktop")
    ("XDG_DOCUMENTS_DIR" . "$HOME/doc")
    ("XDG_DOWNLOAD_DIR" . "$HOME/dw")
    ("XDG_MUSIC_DIR" . "$HOME/music")
    ("XDG_PICTURES_DIR" . "$HOME/pic")
    ("XDG_PUBLICSHARE_DIR" . "$HOME/.local/public")
    ("XDG_TEMPLATES_DIR" . "$HOME/.local/templates")
    ("XDG_VIDEOS_DIR" . "$HOME/vid")

    ;; Custom Variables
    ("CRAWL_DIR" . "$XDG_DATA_HOME/crawl/")
    ("PASSWORD_STORE_DIR" . "$XDG_DATA_HOME/pass")
    ("PASSWORD_STORE_ENABLE_EXTENSIONS_DEFAULT" . "true")
    ("PYTHON_HISTORY" . "$XDG_DATA_HOME/python/history")
    ("WINEPREFIX" . "$XDG_DATA_HOME/wineprefixes/default")
    ;; Tools defaults
    ("XZ_DEFAULTS" . "-T 0")
    ("GRIM_DEFAULT_DIR" . "$HOME/pic/shots")
    ("TERMINFO" . "$XDG_DATA_HOME/terminfo")
    ("TERMINFO_DIRS" . "$XDG_DATA_HOME/terminfo:/usr/share/terminfo")))

(define environment-service
  (simple-service 'user-environment-vars
                  home-environment-variables-service-type
                  environment-vars))
