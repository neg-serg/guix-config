(define-module (home modules git)
  #:use-module (gnu home services)
  #:use-module (gnu home services version-control)
  #:use-module (guix gexp)
  #:export (git-service))

(define git-config
  (home-git-configuration
   (user-name "Sergey Miroshnichenko")
   (user-email "serg.zorg@gmail.com")
   (config
    `((core ((pager . "delta")
             (editor . "nvim")
             (whitespace . "trailing-space,cr-at-eol")
             (ui . "auto")
             (sshCommand . "ssh -i ~/.ssh/id_neg")))
      (init ((defaultBranch . "main")))
      (fetch ((shallow . #t)))
      (pull ((rebase . #t)))
      (push ((default . "simple")))
      (diff ((tool . "nvimdiff")
             (colorMoved . "default")))
      (merge ((tool . "nvimdiff")))
      (alias ((ap . "add --patch")
              (dts . "!delta --side-by-side --color-only")
              (hub . "!gh")
              (st . "status")
              (co . "checkout")
              (ci . "commit")
              (br . "branch")
              (lg . "log --oneline --graph --decorate")))
      (credential ((helper . "!pass-git-helper --file ~/.config/git/pass.yml")))
      (delta ((inspect-raw-lines . #t)
              (line-numbers . #t)
              (side-by-side . #f)
              (syntax-theme . "base16-256")))
      (url "git@github.com:" ((insteadOf . "https://github.com/")))))))

(define git-service
  (simple-service 'user-git-service
                  home-git-service-type
                  git-config))
