(define-module (home home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (home modules shell)
  #:use-module (home modules git)
  #:use-module (home modules cli)
  #:use-module (home modules tmux)
  #:use-module (home modules environment)
  #:use-module (home modules mpv))

(home-environment
 (packages (list)) ; Packages are handled via modules/cli.scm
 (services
  (list
   shell-service
   git-service
   cli-packages-service
   tmux-service
   environment-service
   mpv-service
   (service home-bash-service-type))))
