;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ============================================================
;; Startup optimizations
;; ============================================================

;; Temporarily raise the GC threshold during startup.
;; This reduces GC interruptions while Doom/Emacs loads packages.
(setq gc-cons-threshold most-positive-fixnum)

;; Restore a reasonable GC threshold after startup.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1024 1024))))

;; Allow larger chunks of process output.
(setq read-process-output-max (* 1024 1024))

;; Avoid unnecessary JSON float precision.
(setq json-serialize-precision 0)


;; ============================================================
;; Custom Lisp / Theme load path
;; ============================================================

(add-to-list 'load-path "~/.config/doom/lisp/")
(add-to-list 'custom-theme-load-path "~/.config/doom/lisp/")


;; ============================================================
;; Theme & UI
;; ============================================================

(load! "lisp/mechanoonna-tomorrow-theme")


;; (defun my/omarchy-theme ()
;;   "Return the current Omarchy theme name."
;;   (let ((file (expand-file-name
;;                "~/.config/omarchy/current/theme.name")))
;;     (when (file-readable-p file)
;;       (string-trim
;;        (with-temp-buffer
;;          (insert-file-contents file)
;;          (buffer-string))))))

(defun my/omarchy-theme ()
  "Return the current Omarchy theme name, normalized to lowercase."
  (when-let ((theme (executable-find "omarchy-theme-current")))
    (let ((name (string-trim
                 (with-temp-buffer
                   (call-process theme nil t nil)
                   (buffer-string)))))
      (unless (string-empty-p name)
        (downcase name)))))


(defun my/omarchy-emacs-theme ()
  "Return the Emacs theme corresponding to the current Omarchy theme."
  (pcase (my/omarchy-theme)

    ;; ----------------------------------------------------------
    ;; Custom Omarchy themes
    ;; ----------------------------------------------------------

    ("mechanoonna"
     'mechanoonna-tomorrow)

    ("one-dark-pro"
     'doom-one)


    ;; ----------------------------------------------------------
    ;; Omarchy stock themes
    ;; ----------------------------------------------------------

    ("tokyo-night"
     'doom-tokyo-night)

    ("catppuccin"
     'catppuccin)

    ("catppuccin-latte"
     'catppuccin)

    ("ethereal"
     'doom-ephemeral)

    ("everforest"
     'doom-miramare)

    ("flexoki-dark"
     'modus-vivendi)

    ("flexoki-light"
     'modus-operandi)

    ("gruvbox"
     'doom-gruvbox)

    ("hackerman"
     'doom-1337)

    ("kanagawa"
     'kanagawa-wave)

    ("lumon"
     'doom-city-lights)

    ("matte-black"
     'doom-homage-black)

    ("miasma"
     'doom-miramare)

    ("nord"
     'doom-nord)

    ("osaka-jade"
     'doom-peacock)

    ("retro-82"
     'doom-laserwave)

    ("ristretto"
     'doom-monokai-ristretto)

    ("rose-pine"
     'rose-pine-color)

    ("vantablack"
     'doom-homage-black)

    ("white"
     'doom-flatwhite)


    ;; ----------------------------------------------------------
    ;; Safe fallback
    ;; ----------------------------------------------------------

    (_
     'doom-one)))


(defun omarchy-emacs-reload ()
  "Reload Emacs with the theme currently selected in Omarchy."
  (interactive)

  (let ((omarchy-theme (my/omarchy-theme))
        (emacs-theme (my/omarchy-emacs-theme)))

    ;; Disable currently active themes.
    (mapc #'disable-theme custom-enabled-themes)


    ;; Load the selected theme.
    (load-theme emacs-theme t)

    ;; Mechanoonna-specific customizations.
    (when (equal omarchy-theme "mechanoonna")
      (my/apply-mechanoonna-faces))

    ;; Force a modeline redraw.
    (force-mode-line-update t)))

;; Doom's startup theme.
(setq doom-theme (my/omarchy-emacs-theme))

(setq display-line-numbers-type t)


;; ============================================================
;; Mechanoonna UI refinements
;; ============================================================

(defun my/apply-mechanoonna-faces ()
  "Apply the custom UI faces used by the Mechanoonna theme."

  (custom-set-faces

   ;; ----------------------------------------------------------
   ;; Window dividers
   ;; ----------------------------------------------------------

   '(vertical-border
     ((t (:foreground "#1c1b19"
          :background "#1c1b19"))))

   '(window-divider
     ((t (:foreground "#1c1b19"))))

   '(window-divider-first-pixel
     ((t (:foreground "#1c1b19"))))

   '(window-divider-last-pixel
     ((t (:foreground "#1c1b19"))))


   ;; ----------------------------------------------------------
   ;; Line numbers
   ;; ----------------------------------------------------------

   '(line-number
     ((t (:foreground "#6b655c"
          :background "#171614"))))

   '(line-number-current-line
     ((t (:foreground "#f0e4c5"
          :background "#171614"
          :weight bold))))


   ;; ----------------------------------------------------------
   ;; Modeline
   ;; ----------------------------------------------------------

   '(mode-line
     ((t (:foreground "#f0e4c5"
          :background "#242321"
          :box nil
          :weight normal))))

   '(mode-line-inactive
     ((t (:foreground "#6b655c"
          :background "#1c1b19"
          :box nil
          :weight normal))))

   '(mode-line-buffer-id
     ((t (:foreground "#d8c486"
          :background "#242321"
          :weight bold
          :box nil))))


   ;; ----------------------------------------------------------
   ;; Org drawers / properties
   ;; ----------------------------------------------------------

   '(org-drawer
     ((t (:foreground "#96928a"))))

   '(org-property-value
     ((t (:foreground "#96928a"))))


   ;; ----------------------------------------------------------
   ;; Dirvish
   ;; ----------------------------------------------------------

   '(dirvish-file-time
     ((t (:foreground "#70675b"))))


   ;; ----------------------------------------------------------
   ;; Nerd Icons
   ;; ----------------------------------------------------------

   '(nerd-icons-purple
     ((t (:foreground "#cbb994"))))

   '(nerd-icons-blue
     ((t (:foreground "#908d88"))))

   '(nerd-icons-cyan
     ((t (:foreground "#cbb994"))))

   '(nerd-icons-green
     ((t (:foreground "#a89972"))))

   '(nerd-icons-yellow
     ((t (:foreground "#d8c486"))))

   '(nerd-icons-orange
     ((t (:foreground "#c58a55"))))

   '(nerd-icons-red
     ((t (:foreground "#9a6b52"))))))


;;Apply Mechanoonna faces during initial startup.
(when (equal (my/omarchy-theme) "mechanoonna")
  (my/apply-mechanoonna-faces))




;; ============================================================
;; Vertico
;; ============================================================

(setq vertico-cycle t
      vertico-resize t)

;; (after! vertico
;;   ;; Navigate between Vertico groups.
;;   (map! :map vertico-map
;;         "C-" #'vertico-next-group
;;         "C-" #'vertico-previous-group))


;; ============================================================
;; General keybindings
;; ============================================================

(map! :g "M-o" #'my/other-window-or-split)


;; ============================================================
;; Window utility
;; ============================================================

(defun my/other-window-or-split ()
  "Switch to the other window, creating a split if necessary."
  (interactive)
  (if (one-window-p)
      (progn
        (split-window-right)
        (other-window 1))
    (other-window 1)))


;; ============================================================
;; Consult Omni
;; ============================================================

;; Omni is intentionally loaded lazily.
;; This keeps the startup path lighter while still making the
;; commands available immediately when invoked.

(defun my/omni--ensure-loaded ()
  "Load all personal Consult Omni modules."
  ;; Built-in Consult Omni modules.
  (require 'consult-omni-fd)
  (require 'consult-omni-apps)
  (require 'consult-omni-calc)

  ;; omni-local / UI / frame system.
  (require 'omni-local)

  ;; Personal sources.
  (require 'omni-org-sources)
  (require 'omni-denote-sources)
  (require 'omni-omarchy-sources)
  (require 'omni-projectile-sources)

  ;; Search engines.
  (require 'omni-search-engines))


;;;###autoload
(defun my/omni-local ()
  "Open the personal local Omni interface."
  (interactive)
  (my/omni--ensure-loaded)
  (call-interactively #'my/omni-local-real))


;;;###autoload
(defun my/omni-web ()
  "Open the personal web Omni interface."
  (interactive)
  (my/omni--ensure-loaded)
  (call-interactively #'my/omni-web-real))


;; Preload Omni shortly after startup so the first interactive
;; invocation does not have to pay the entire loading cost.
(run-with-idle-timer
 2
 nil
 #'my/omni--ensure-loaded)


;; Remove width padding from Consult Omni App results.
(with-eval-after-load 'consult-omni
  (defun my-consult-no-width-padding (string width)
    "Return STRING without adding width padding."
    string)

  (advice-add
   'consult-omni--set-string-width
   :override
   #'my-consult-no-width-padding))


;; Open selected Consult Omni projects directly in Dired.
;; (after! consult-omni
;;   (defun my/consult-omni-project-open (project)
;;     "Open PROJECT directly in Dired."
;;     (projectile-dired project))

;;   (setq consult-omni-projects-callback-func
;;         #'my/consult-omni-project-open))



;; ============================================================
;; Consult file actions
;; ============================================================

;; Customize Consult's file-selection action globally.
;; Large files, media, documents, archives, etc. are opened
;; with the system application. Directories and normal files
;; are opened through the dedicated Emacs "omni" perspective.
(load! "lisp/consult-file-actions.el")


;; ============================================================
;; Cape completion
;; ============================================================

(use-package! cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

(setq cape-dabbrev-min-length 3
      cape-dabbrev-check-other-buffers t
      cape-dabbrev-check-all-buffers t)


;; ============================================================
;; Org-ql
;; ============================================================

;; Load Org QL only after Org itself is available.
(use-package! org-ql
  :after org)


;; ============================================================
;; Org Capture lazy loading
;; ============================================================

;; org-setup.el contains the complete Org capture implementation.
;; Keep both entry points autoloaded so Emacs knows about them
;; without loading the entire Org setup during startup.

;;;###autoload
(autoload 'my/org-capture-grouped
  "org-setup"
  "Open the grouped Org capture menu."
  t)

;;;###autoload
(autoload 'my/org-capture-grouped-wl
  "org-setup"
  "Open the grouped Org capture menu using region or Wayland clipboard."
  t)


;; ============================================================
;; Dirvish
;; ============================================================

(load! "lisp/dirvish-setup.el")


;; ============================================================
;; Denote
;; ============================================================

(use-package! denote
  :config
  (setq denote-directory "~/Knowledge/"))


;; ============================================================
;; Elfeed
;; ============================================================

;; Load the personal Elfeed configuration only after Elfeed
;; itself has been loaded.
(after! elfeed
  (load! "lisp/elfeed-setup.el"))



;; ============================================================
;; Avy
;; ============================================================

(use-package! avy
  :commands (avy-goto-char-timer avy-isearch)
  :init
  (map! "C-." #'avy-goto-char-timer)
  :config
  (load! "lisp/avy-setup.el"))



;; ============================================================
;; Eshell improvements
;; ============================================================

(after! eshell

  (defun eshell/z (&optional regexp)
    "Jump to a previously visited directory in Eshell."
    (let* ((eshell-dirs
            (delete-dups
             (mapcar #'abbreviate-file-name
                     (ring-elements eshell-last-dir-ring)))))

      (cond
       ;; With no argument, use Consult Dir when available.
       ((and (not regexp)
             (require 'consult-dir nil t))
        (let* ((source
                `(:name "Eshell"
                  :narrow ?e
                  :category file
                  :face consult-file
                  :items ,eshell-dirs))
               (consult-dir-sources
                (cons source consult-dir-sources)))

          (eshell/cd
           (substring-no-properties
            (consult-dir--pick "Switch directory: ")))))

       ;; With a regexp, use Eshell's normal history search.
       (regexp
        (eshell/cd
         (eshell-find-previous-directory regexp)))

       ;; Otherwise use a normal completion prompt.
       (t
        (eshell/cd
         (completing-read "cd: " eshell-dirs nil t)))))))


;; ============================================================
;; System utility autoloads
;; ============================================================

;;;###autoload
(autoload 'my/usb-mount-unmount
  "usb-tools"
  "Mount or unmount a USB partition interactively."
  t)

;;;###autoload
(autoload 'my/sys-package-manager
  "sys-pkg"
  "Open the system package manager."
  t)

;;;###autoload
(autoload 'my/sys-pkg-multi-operation
  "sys-pkg"
  "Run a package manager operation on multiple packages."
  t)

;; ============================================================
;; TMR
;; ============================================================


(use-package! tmr
  :commands (tmr tmr-with-details)
  :bind-keymap
  ("C-c r" . tmr-prefix-map)
  :config
  (setq tmr-sound-file
        "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
        tmr-notification-urgency 'normal
        tmr-description-list 'tmr-description-history))

;; ============================================================
;; GPTel
;; ============================================================

;; (after! gptel
;;   (load! "lisp/gptel-setup"))



;; ============================================================
;; Devil mode
;; ============================================================

(use-package! devil
  :config
  (global-devil-mode 1))


;; ============================================================
;; Devil custom repeatable key groups
;; ============================================================

(after! devil

  ;; ------------------------------------------------------------
  ;; Remove standalone C-s group.
  ;; We'll replace it with a C-s / C-r group below.
  ;; ------------------------------------------------------------

  (setq devil-repeatable-keys
        (seq-remove
         (lambda (group)
           (equal group '("%k s")))
         devil-repeatable-keys))


  ;; ------------------------------------------------------------
  ;; Extend Devil's existing marking group
  ;; ------------------------------------------------------------
  ;;
  ;; ,m@    = M-@     = mark-word
  ;; ,mh     = M-h     = mark-paragraph
  ;; ,mmSPC  = C-M-SPC = mark-sexp
  ;;

  (setq devil-repeatable-keys
        (mapcar
         (lambda (group)
           (if (equal group '("%k m @" "%k m h"))
               '("%k m @" "%k m h" "%k m m SPC")
             group))
         devil-repeatable-keys))


  ;; ------------------------------------------------------------
  ;; Add custom groups
  ;; ------------------------------------------------------------

  (setq devil-repeatable-keys
        (append
         devil-repeatable-keys

         '(
           ;; ------------------------------------------------------------
           ;; Structural navigation / editing
           ;; ------------------------------------------------------------
           ;;
           ;; Definition-level:
           ;;
           ;; ,mma    = C-M-a   = beginning-of-defun
           ;; ,mme    = C-M-e   = end-of-defun
           ;; ,mmh    = C-M-h   = mark-defun
           ;;
           ;; S-expression:
           ;;
           ;; ,mmb    = C-M-b   = backward-sexp
           ;; ,mmf    = C-M-f   = forward-sexp
           ;;
           ;; List structure:
           ;;
           ;; ,mmd    = C-M-d   = down-list
           ;; ,mmu    = C-M-u   = backward-up-list
           ;; ,mmn    = C-M-n   = forward-list
           ;; ,mmp    = C-M-p   = backward-list
           ;;
           ;; Editing:
           ;;
           ;; ,mmk    = C-M-k   = kill-sexp
           ;; ,mmDEL  = C-M-DEL = backward-kill-sexp
           ;; ,mmSPC  = C-M-SPC = mark-sexp
           ;;
           ("%k m m a"
            "%k m m e"
            "%k m m h"
            "%k m m b"
            "%k m m f"
            "%k m m d"
            "%k m m u"
            "%k m m n"
            "%k m m p"
            "%k m m k"
            "%k m m DEL"
            "%k m m SPC")

           ;; ------------------------------------------------------------
           ;; Word / higher-level text navigation
           ;; ------------------------------------------------------------
           ;;
           ;; ,mb = M-b = backward-word
           ;; ,mf = M-f = forward-word
           ;;
           ;; ,m{ = M-{ = backward-paragraph
           ;; ,m} = M-} = forward-paragraph
           ;;
           ;; ,m< = M-< = beginning-of-buffer
           ;; ,m> = M-> = end-of-buffer
           ;;
           ("%k m b"
            "%k m f"
            "%k m {"
            "%k m }"
            "%k m <"
            "%k m >")

           ;; --------------------------------------------------
           ;; Search direction
           ;; --------------------------------------------------
           ;;
           ;; ,s = C-s = isearch-forward
           ;; ,r = C-r = isearch-backward
           ;;
           ("%k s"
            "%k r")

           ))))




;; Jump to a character
(map! "C-;" #'jump-char-forward)

;; Surround
(use-package! surround
  :bind-keymap
  ("C-'" . surround-keymap))

;; Embark
(map! "C-\\" #'embark-act)



;; ============================================================
;; Org Browser
;; ============================================================

;; The browser implementation remains lazy-loaded.
(autoload 'my-org-browser-show
  "org-browser"
  "Open the Org Browser two-pane browser."
  t)

(map! :leader
      :desc "Org browser"
      "n b" #'my-org-browser-show)


;; ============================================================
;; Workspaces
;; ============================================================

(load! "lisp/workspaces-setup.el")


;; ============================================================
;; Lightemacs improvements
;; ============================================================

;; Load this after Doom initialization.
;; Errors are caught so a problem here does not prevent the rest
;; of the configuration from loading.
(add-hook 'doom-after-init-hook
          (lambda ()
            (condition-case err
                (load! "lisp/lightemacs-setup.el")
              (error
               (message "Lightemacs setup failed: %s" err)))))

;;; config.el ends here
