(global-font-lock-mode 1)

(put 'narrow-to-region 'disabled nil)

(put 'downcase-region 'disabled nil)

;; Simple Lisp Files
(add-to-list 'load-path "~/.site-lisp/el")
(add-to-list 'load-path "~/.site-lisp/rinari")
(add-to-list 'load-path "~/settings/site-lisp/el")
(add-to-list 'load-path "~/settings/site-lisp/rinari")
(add-to-list 'load-path "~/settings/site-lisp/ruby-mode")

(require 'ruby-mode)
(require 'pabbrev)

(require 'google-c-style)

;; Interactively Do Things (highly recommended, but not strictly required)
;;(require 'ido)
;;(ido-mode t)
     
;; Rinari -- only load this if we're on newer emacs
(when (>= emacs-major-version 22)
  (require 'rinari)
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(gud-gdb-command-name "gdb --annotate=1")
   '(large-file-warning-threshold nil)
   (custom-set-faces
    ;; custom-set-faces was added by Custom.
    ;; If you edit it by hand, you could mess it up, so be careful.
    ;; Your init file should contain only one such instance.
    ;; If there is more than one, they won't work right.
    )
))

; Code Cleanup for Emacs V1.0
;; http://blog.modp.com/2008/11/handy-emacs-functions-for-code-cleanup.html
;; PUBLIC DOMAIN

;; zap tabs
;;
(defun buffer-untabify ()
  "Untabify an entire buffer"
  (interactive)
  (untabify (point-min) (point-max)))

;;
;; re-indent buffer
;;
(defun buffer-indent()
  "Reindent an entire buffer"
  (interactive)
  (indent-region (point-min) (point-max) nil))

;;
;; Untabify, re-indent, make EOL be '\n' not '\r\n'
;;   and delete trailing whitespace
;;
(defun buffer-cleanup()
  "Untabify and re-indent an entire buffer"
  (interactive)
  (if (equal buffer-file-coding-system 'undecided-unix )
      nil
    (set-buffer-file-coding-system 'undecided-unix))
  (setq c-basic-offset 2
        tab-width 2
        indent-tabs-mode nil)
  (buffer-untabify)
  (buffer-indent)
  (delete-trailing-whitespace))
(put 'upcase-region 'disabled nil)
