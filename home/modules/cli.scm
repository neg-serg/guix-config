(define-module (home modules cli)
  #:use-module (gnu home services)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages rust-apps) ; for eza, bat, ripgrep, fd
  #:use-module (gnu packages version-control) ; for tig, git
  #:use-module (gnu packages terminals) ; for kitty, tmux (maybe)
  #:use-module (gnu packages file-systems) ; for disko/usage tools
  #:use-module (gnu packages search) ; for fzf, broot?
  #:use-module (gnu packages admin) ; for btop
  #:use-module (gnu packages curl)
  #:use-module (gnu packages shells) ; for zsh plugins
  #:use-module (guix packages)
  #:export (cli-packages-service))

;; List of packages to install
;; Note: names verified as best effort for Guix
(define cli-packages
  (list
   ;; Core Tools
   (specification->package "coreutils")
   (specification->package "bash")
   (specification->package "zsh")
   
   ;; Modern replacements
   (specification->package "eza")      ; ls replacement
   (specification->package "bat")      ; cat replacement
   (specification->package "ripgrep")  ; grep replacement
   (specification->package "fd")       ; find replacement
   (specification->package "fzf")      ; fuzzy finder
   (specification->package "zoxide")   ; cd replacement
   (specification->package "broot")    ; tree/fm
   
   ;; Git tools
   (specification->package "git")
   (specification->package "git-delta") ; pager
   (specification->package "tig")       ; git tui
   
   ;; Monitoring
   (specification->package "btop")
   (specification->package "bottom")
   
   ;; Network
   (specification->package "curl")
   (specification->package "wget")
   
   ;; Shell plugins (for Zsh sourcing)
   (specification->package "zsh-syntax-highlighting")
   (specification->package "zsh-autosuggestions")
   
   ;; Misc
   (specification->package "neovim")
   (specification->package "tmux")
   (specification->package "starship") ; prompts (oh-my-posh might need manual install/nonguix)
   ))

(define cli-packages-service
  (simple-service 'user-cli-packages
                  home-profile-service-type
                  cli-packages))
