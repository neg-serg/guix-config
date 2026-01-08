(define-module (home modules shell)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages shellutils)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:export (shell-service))

;; Aliases ported from lib/aliae.nix
(define shell-aliases
  '(("ls" . "eza --icons=auto --hyperlink")
    ("l" . "eza --icons=auto --hyperlink -lbF --git")
    ("ll" . "eza --icons=auto --hyperlink -lbGF --git")
    ("la" . "eza --icons=auto --hyperlink -lbhHigUmuSa --time-style=long-iso --git --color-scale")
    ("lt" . "eza --icons=auto --hyperlink --tree --level=2")
    ("cat" . "bat -pp")
    ("g" . "git")
    ("gs" . "git status -sb")
    ("ga" . "git add")
    ("gc" . "git commit -v")
    ("gd" . "git diff")
    ("gp" . "git push")
    ("gl" . "git log --oneline --graph")
    ("cp" . "cp --reflink=auto")
    ("mv" . "mv -i")
    ("mk" . "mkdir -p")
    ("rd" . "rmdir")
    ("j" . "journalctl")
    ("ip" . "ip -c")
    ("rsync" . "rsync -az --info=progress2")
    ("nrb" . "sudo -E guix system reconfigure"))) ;; Adapting nrb for Guix? Or keep nixos-rebuild if on NixOS?
    ;; User is porting TO Guix Home on Guix System (or nonguix). "nrb" was nixos-rebuild.
    ;; I'll leave it as comment or adapt to guix home reconfigure

(define zsh-config
  (home-zsh-configuration
   (xdg-flavor? #t)
   (environment-variables
    '(("ZDOTDIR" . "$HOME/.config/zsh")
      ("XDG_DATA_HOME" . "$HOME/.local/share")
      ("XDG_CONFIG_HOME" . "$HOME/.config")
      ("XDG_CACHE_HOME" . "$HOME/.cache")
      ("XDG_STATE_HOME" . "$HOME/.local/state")
      ("PASSWORD_STORE_DIR" . "$XDG_DATA_HOME/pass")
      ("EDITOR" . "nvim")
      ("MANWIDTH" . "80")
      ("KEYTIMEOUT" . "10")))
   (aliases shell-aliases)
   (zshrc
    (list
     ;; Initialize plugins
     (plain-file "zsh-plugins"
                 (string-append
                  "# Plugins\n"
                  "source $HOME/.guix-home/profile/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\n"
                  "source $HOME/.guix-home/profile/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh\n"))
     ;; Oh-my-posh (if available in profile)
     (plain-file "oh-my-posh-init"
                 "if command -v oh-my-posh > /dev/null; then\n  eval \"$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/config.json)\"\nfi\n")))
   (zshenv
    (list
     (plain-file "zshenv-extra"
                 "skip_global_compinit=1\n")))))

(define shell-service
  (simple-service 'user-shell-service
                  home-zsh-service-type
                  zsh-config))
