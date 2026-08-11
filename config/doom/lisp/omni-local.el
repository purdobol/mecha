;;; omni-local.el --- Local Consult-Omni search and floating frame -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; Author: [azg@work](mailto:azg@work)
;; Keywords:

;;; Commentary:
;; Defines the local Omni search experience:
;;
;; 1. Configures fd for fast personal-file searching.
;; 2. Defines the sources used by consult-omni-local.
;; 3. Provides the native floating-frame UI.
;; 4. Exposes my/omni-local-real as the frame-based entry point.
;;
;; Loading of this file is handled externally by the Omni lazy-loader.

;;; Code:

;; --------------------------------------------------
;; fd configuration
;; --------------------------------------------------
;; Local fd search intentionally excludes configuration, cache, application
;; data, and other directories that are not useful for normal file search.
;; Knowledge and org are excluded because they have dedicated Omni sources.

(defvar my-consult-omni-fd-command
  (if (executable-find "fdfind")
      "fdfind"
    "fd"))

(setq consult-omni-fd-args
      (append
       (list
        my-consult-omni-fd-command
        "--full-path"
        "--color=never"
        "--follow")
       (mapcan
        (lambda (dir)
          (list "--exclude" dir))
        '(".git"
          ".config"
          ".local"
          ".cache"
          ".steam"
          ".wine"
          "node_modules"
          "Knowledge"
          "org"))))

;; --------------------------------------------------
;; Local search sources
;; --------------------------------------------------
;; These are the sources presented by consult-omni-local.
;; Each source has a dedicated purpose, keeping the local launcher focused
;; on frequently useful personal and development resources.

(defvar consult-omni-local-sources
  '("calc"
    "fd"
    "OrgBookmarks"
    "OrgHeadings"
    "Denote"
    "Omarchy"
    "Apps"
    "Projectile"))

(defun consult-omni-local ()
  "Fast local search."
  (interactive)
  (let ((consult-async-input-debounce 0)
        (consult-async-input-throttle 0)
        (consult-async-refresh-delay 0))
    (consult-omni-multi
     nil
     "[consult-omni-local] Search: "
     consult-omni-local-sources)))

;; --------------------------------------------------
;; Omni frame state
;; --------------------------------------------------
;; The frame is created on demand and removed when the search command exits.

(defvar my/omni-frame nil)
(defvar my/omni-buffer "*omni*")
(defvar my/omni-current-mode nil)

;; --------------------------------------------------
;; Frame creation
;; --------------------------------------------------
;; Creates the undecorated floating frame used by the local Omni launcher.
;; Width and height are specified in character units.

(defun my/omni--make-frame (width height)
  (let* ((char-w (frame-char-width))
         (char-h (frame-char-height))
         (pixel-width (* width char-w))
         (pixel-height (* height char-h))
         (left (/ (- (display-pixel-width) pixel-width) 2))
         (top (/ (- (display-pixel-height) pixel-height) 2)))
    (make-frame
     `((name . "omni")
       (width . ,width)
       (height . ,height)
       (left . ,(max left 0))
       (top . ,(max top 0))
       (undecorated . t)
       (skip-taskbar . t)
       (minibuffer . t)
       (internal-border-width . 4)
       (menu-bar-lines . 0)
       (tool-bar-lines . 0)
       (vertical-scroll-bars . nil)))))

;; --------------------------------------------------
;; Header renderer
;; --------------------------------------------------
;; Displays the centered title/subtitle shown above the Consult minibuffer.

(defun my/omni-render-header (title subtitle)
  (setq buffer-read-only nil)
  (erase-buffer)

  (let* ((usable-width (window-body-width))
         (padding
          (make-string
           (max 0
                (/ (- usable-width (string-width title)) 2))
           ?\s))
         (sub-padding
          (make-string
           (max 0
                (/ (- usable-width (string-width subtitle)) 2))
           ?\s)))
    (insert "\n\n\n")
    (insert
     padding
     (propertize
      title
      'face '(:inherit font-lock-keyword-face
              :height 2.0
              :weight bold))
     "\n")
    (insert
     sub-padding
     (propertize
      subtitle
      'face '(:inherit font-lock-function-name-face
              :weight semi-bold))
     "\n\n"))

  (setq buffer-read-only t))

;; --------------------------------------------------
;; Core frame launcher
;; --------------------------------------------------
;; Creates the floating frame, prepares its buffer, runs the supplied
;; search function, and cleans up the frame when the search exits.

(defun my/omni-launch (mode width height fn title subtitle)
  (setq my/omni-current-mode mode)

  ;; Close an existing Omni frame before opening a new one.
  (when (frame-live-p my/omni-frame)
    (delete-frame my/omni-frame)
    (setq my/omni-frame nil))

  (setq my/omni-frame
        (my/omni--make-frame width height))

  (with-selected-frame my/omni-frame
    (select-frame-set-input-focus my/omni-frame)

    (let ((buf (get-buffer-create my/omni-buffer)))
      (switch-to-buffer buf)

      ;; Keep the Omni frame visually focused on the search interface.
      (setq-local mode-line-format nil)
      (setq-local header-line-format nil)
      (setq-local cursor-type nil)

      (my/omni-render-header title subtitle)

      ;; Always clean up the floating frame when the search exits.
      (unwind-protect
          (funcall fn)
        (when (frame-live-p my/omni-frame)
          (delete-frame my/omni-frame))
        (setq my/omni-frame nil)))))

;; --------------------------------------------------
;; Public local launcher
;; --------------------------------------------------
;; This is the command called by the lazy-loaded Omni entry point.

(defun my/omni-local-real ()
  (interactive)
  (my/omni-launch
   'local
   110 28
   #'consult-omni-local
   "omni.local"
   "/ indexing / memory / context / execution /"))

(provide 'omni-local)

;;; omni-local.el ends here
