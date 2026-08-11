;;; lightemacs-setup.el -*- lexical-binding: t; -*-


(require 'cl-lib)


;;; ============================================================
;;; Lightemacs-inspired Doom improvements
;;; ============================================================


;;; ------------------------------------------------------------
;;; Core Emacs state persistence
;;; ------------------------------------------------------------

;; Return to last position in files
(save-place-mode +1)


;; Remember minibuffer history
(savehist-mode +1)




;; Store state in Doom cache instead of home directory

(setq savehist-file
      (expand-file-name "savehist"
                        doom-cache-dir))


;;; ------------------------------------------------------------
;;; Cleaner Emacs defaults
;;; ------------------------------------------------------------

;; Better prompts
;;(fset 'yes-or-no-p 'y-or-n-p)


;; UTF-8 everywhere
(set-language-environment "UTF-8")

(setq-default buffer-file-coding-system 'utf-8-unix)


;; Follow symlinks without asking
(setq vc-follow-symlinks t)


;; Automatically reload files changed externally
(global-auto-revert-mode +1)

(setq global-auto-revert-non-file-buffers t)



;;; ============================================================
;;; Packages
;;; ============================================================

;; Packages are declared here because Doom already handles
;; package installation through straight.el

(after! gcmh
  (gcmh-mode +1))


;;; ------------------------------------------------------------
;;; Buffer management
;;; ------------------------------------------------------------


;; Needs testing
;;
;;(after! buffer-guardian
;;  (buffer-guardian-mode +1))



;;; ------------------------------------------------------------
;;; Persistent text zoom
;;; ------------------------------------------------------------

(after! persist-text-scale
  (persist-text-scale-mode +1))



;;; ------------------------------------------------------------
;;; Indentation detection
;;; ------------------------------------------------------------

(after! dtrt-indent
  (add-hook! '(python-mode
               go-mode
               rust-mode
               c-mode
               c++-mode)
             #'dtrt-indent-mode))

;;; ------------------------------------------------------------
;;; Expand region
;;; ------------------------------------------------------------

(after! expand-region

  (map!
   "C-="
   #'er/expand-region))



;;; ------------------------------------------------------------
;;; Visual undo
;;; ------------------------------------------------------------

(after! vundo

  (map!
   :leader
   :desc "Visual undo"
   "u"
   #'vundo))



;;; ------------------------------------------------------------
;;; Offline documentation
;;; ------------------------------------------------------------

(after! devdocs

  (map!
   :leader
   :desc "Devdocs lookup"
   "h d"
   #'devdocs-lookup))



;;; ------------------------------------------------------------
;;; Better terminal
;;; ------------------------------------------------------------

;;need to cobmpare to vterm


;; (after! eat

;;   (map!
;;    :leader
;;    :desc "Emacs terminal"
;;    "o t"
;;    #'eat))



(provide 'lightemacs-setup)

;;; lightemacs-setup.el ends here
