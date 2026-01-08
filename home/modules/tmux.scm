(define-module (home modules tmux)
  #:use-module (gnu home services)
  #:use-module (gnu home services tmux)
  #:use-module (guix gexp)
  #:export (tmux-service))

(define tmux-conf-content
  ;; Re-use the existing configuration content
  ;; Note: TPM usage implies manual plugin management or further integration
  (plain-file "tmux.conf"
"# Tmux Configuration (Ported from NixOS)

# Keybindings and Prefix
set -g prefix ^s
unbind C-b
bind C-s last-window
bind C-a send-prefix

# General Options
set -g history-limit 8191
set -g renumber-windows on
set -g mouse on
set -g set-clipboard on
set -g default-terminal \"tmux-256color\"
set -ag terminal-overrides \",xterm-256color:RGB\"

# Vi mode
set-window-option -g mode-keys vi
bind -T copy-mode-vi 'v' send -X begin-selection
bind -T copy-mode-vi 'y' send -X copy-pipe-and-cancel \"wl-copy\"

# Pane Management
bind | split-window -h
bind _ split-window -v
bind -r h resize-pane -L 1
bind -r j resize-pane -D 1
bind -r k resize-pane -U 1
bind -r l resize-pane -R 1

# Status Bar (Kitty-like)
set -g status on
set -g status-interval 1
set -g status-left-length 50
set -g status-right-length 150
set -g status-justify left
set-option -g status-position bottom
set-option -g status-style bg=default,fg=colour15

set -g status-left \"#[fg=colour24,bg=colour0] TMUX #[fg=default,bg=default] \"
set -g window-status-format \"#[fg=colour240] #I #[fg=colour250]#W \"
set -g window-status-current-format \"#[fg=colour24,bold] #I #[fg=colour15,bold]#W \"
set -option -g status-right '#[fg=colour8]%d.%m.%Y #[fg=colour15]%H:%M '

# Plugins (TPM)
# Ensure usage of TPM if sticking to this config
# or replace with Guix Home service extensions
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Initialize TPM
if \"test ! -d ~/.config/tmux/plugins/tpm\" \
   \"run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm'\"
run '~/.config/tmux/plugins/tpm/tpm'
"))

(define tmux-service
  (simple-service 'user-tmux-config
                  home-tmux-service-type
                  (home-tmux-configuration
                   (tmux (specification->package "tmux"))
                   (config tmux-conf-content))))
