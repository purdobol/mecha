;;; omarchy-emacs.el --- Apply Omarchy colors to Emacs -*- lexical-binding: t; -*-

(require 'cl-lib)

(defgroup omarchy-emacs nil
  "Use the current Omarchy palette in Emacs."
  :group 'faces)

(defcustom omarchy-emacs-colors-file
  (expand-file-name "~/.config/omarchy/current/theme/colors.toml")
  "Path to Omarchy's current colors.toml."
  :type 'file
  :group 'omarchy-emacs)

(defvar omarchy-emacs--colors nil)

(defun omarchy-emacs--read-colors ()
  "Read simple key/value colors from Omarchy's colors.toml."
  (unless (file-readable-p omarchy-emacs-colors-file)
    (error "Cannot read %s" omarchy-emacs-colors-file))

  (let (colors)
    (with-temp-buffer
      (insert-file-contents omarchy-emacs-colors-file)
      (goto-char (point-min))

      (while
          (re-search-forward
           "^[[:space:]]*\\([[:alnum:]_-]+\\)[[:space:]]*=[[:space:]]*\"\\(#[[:xdigit:]]+\\)\""
           nil
           t)

        (push
         (cons
          (intern (match-string-no-properties 1))
          (match-string-no-properties 2))
         colors)))

    colors))

(defun omarchy-emacs--color (name &optional fallback)
  "Return Omarchy color NAME, or FALLBACK."
  (or (cdr (assq name omarchy-emacs--colors))
      fallback))

(defun omarchy-emacs--palette ()
  "Build a semantic palette from Omarchy's ANSI colors."
  (let ((background
         (or (omarchy-emacs--color 'background)
             (omarchy-emacs--color 'color0)))

        (foreground
         (or (omarchy-emacs--color 'foreground)
             (omarchy-emacs--color 'color7)))

        (selection
         (or (omarchy-emacs--color 'selection_background)
             (omarchy-emacs--color 'selection)
             (omarchy-emacs--color 'color8)))

        (comment
         (or (omarchy-emacs--color 'color8)
             (omarchy-emacs--color 'dark_foreground)
             foreground))

        (red
         (or (omarchy-emacs--color 'red)
             (omarchy-emacs--color 'color1)))

        (orange
         (or (omarchy-emacs--color 'orange)
             (omarchy-emacs--color 'color3)))

        (yellow
         (or (omarchy-emacs--color 'yellow)
             (omarchy-emacs--color 'color3)))

        (green
         (or (omarchy-emacs--color 'green)
             (omarchy-emacs--color 'color2)))

        (cyan
         (or (omarchy-emacs--color 'cyan)
             (omarchy-emacs--color 'color6)))

        (blue
         (or (omarchy-emacs--color 'blue)
             (omarchy-emacs--color 'color4)))

        (purple
         (or (omarchy-emacs--color 'purple)
             (omarchy-emacs--color 'magenta)
             (omarchy-emacs--color 'color5))))

    `((background . ,background)
      (foreground . ,foreground)
      (selection . ,selection)
      (comment . ,comment)
      (red . ,red)
      (orange . ,orange)
      (yellow . ,yellow)
      (green . ,green)
      (cyan . ,cyan)
      (blue . ,blue)
      (purple . ,purple))))

(defun omarchy-emacs--palette-color (name)
  "Get semantic color NAME."
  (cdr (assq name (omarchy-emacs--palette))))

(defun omarchy-emacs--set-face (face &rest attributes)
  "Set FACE ATTRIBUTES if FACE exists."
  (when (facep face)
    (apply #'set-face-attribute face nil attributes)))

(defun omarchy-emacs--apply-faces ()
  "Apply Omarchy colors to common Emacs faces."

  (let ((bg       (omarchy-emacs--palette-color 'background))
        (fg       (omarchy-emacs--palette-color 'foreground))
        (selection (omarchy-emacs--palette-color 'selection))
        (comment  (omarchy-emacs--palette-color 'comment))
        (red      (omarchy-emacs--palette-color 'red))
        (orange   (omarchy-emacs--palette-color 'orange))
        (yellow   (omarchy-emacs--palette-color 'yellow))
        (green    (omarchy-emacs--palette-color 'green))
        (cyan     (omarchy-emacs--palette-color 'cyan))
        (blue     (omarchy-emacs--palette-color 'blue))
        (purple   (omarchy-emacs--palette-color 'purple)))

    ;; Do not allow nil colors through to Emacs.
    (unless (and bg fg red yellow green blue)
      (error "Incomplete Omarchy palette: %S"
             omarchy-emacs--colors))

    ;; Basic UI.
    (omarchy-emacs--set-face
     'default
     :foreground fg
     :background bg)

    (omarchy-emacs--set-face
     'cursor
     :foreground bg
     :background fg)

    (omarchy-emacs--set-face
     'region
     :foreground fg
     :background selection)

    (omarchy-emacs--set-face
     'highlight
     :background selection)

    (omarchy-emacs--set-face
     'hl-line
     :background selection)

    ;; Modeline.
    (omarchy-emacs--set-face
     'mode-line
     :foreground fg
     :background selection)

    (omarchy-emacs--set-face
     'mode-line-inactive
     :foreground comment
     :background bg)

    ;; Syntax.
    (omarchy-emacs--set-face
     'font-lock-comment-face
     :foreground comment)

    (omarchy-emacs--set-face
     'font-lock-comment-delimiter-face
     :foreground comment)

    (omarchy-emacs--set-face
     'font-lock-keyword-face
     :foreground purple)

    (omarchy-emacs--set-face
     'font-lock-builtin-face
     :foreground cyan)

    (omarchy-emacs--set-face
     'font-lock-function-name-face
     :foreground blue)

    (omarchy-emacs--set-face
     'font-lock-variable-name-face
     :foreground red)

    (omarchy-emacs--set-face
     'font-lock-type-face
     :foreground yellow)

    (omarchy-emacs--set-face
     'font-lock-constant-face
     :foreground orange)

    (omarchy-emacs--set-face
     'font-lock-string-face
     :foreground green)

    ;; Diagnostics.
    ;;
    ;; Explicitly specify a real color. This prevents:
    ;;
    ;; Invalid face underline :style wave :color nil
    ;;
    (omarchy-emacs--set-face
     'flycheck-error
     :underline (list :style 'wave :color red))

    (omarchy-emacs--set-face
     'flycheck-warning
     :underline (list :style 'wave :color yellow))

    (omarchy-emacs--set-face
     'flycheck-info
     :underline (list :style 'wave :color green))

    (omarchy-emacs--set-face
     'flymake-error
     :underline (list :style 'wave :color red))

    (omarchy-emacs--set-face
     'flymake-warning
     :underline (list :style 'wave :color yellow))

    (omarchy-emacs--set-face
     'flymake-note
     :underline (list :style 'wave :color green))

    ;; Standard diagnostic faces.
    (omarchy-emacs--set-face
     'error
     :foreground red)

    (omarchy-emacs--set-face
     'warning
     :foreground yellow)

    (omarchy-emacs--set-face
     'success
     :foreground green)

    ;; Links.
    (omarchy-emacs--set-face
     'link
     :foreground blue
     :underline t)

    (omarchy-emacs--set-face
     'link-visited
     :foreground purple
     :underline t)

    ;; Search.
    (omarchy-emacs--set-face
     'isearch
     :foreground fg
     :background blue)

    (omarchy-emacs--set-face
     'lazy-highlight
     :background selection)

    ;; Minibuffer.
    (omarchy-emacs--set-face
     'minibuffer-prompt
     :foreground blue
     :weight 'bold)

    ;; Dired.
    (omarchy-emacs--set-face
     'dired-directory
     :foreground blue
     :weight 'bold)

    ;; Org.
    (omarchy-emacs--set-face
     'org-level-1
     :foreground blue
     :weight 'bold)

    (omarchy-emacs--set-face
     'org-level-2
     :foreground purple
     :weight 'bold)

    (omarchy-emacs--set-face
     'org-level-3
     :foreground cyan
     :weight 'bold)

    (omarchy-emacs--set-face
     'org-level-4
     :foreground green
     :weight 'bold)

    (omarchy-emacs--set-face
     'org-level-5
     :foreground yellow
     :weight 'bold)

    ;; Completion.
    (omarchy-emacs--set-face
     'completions-common-part
     :foreground blue)

    (omarchy-emacs--set-face
     'completions-first-difference
     :foreground red)

    ;; Diff.
    (omarchy-emacs--set-face
     'diff-added
     :foreground green)

    (omarchy-emacs--set-face
     'diff-removed
     :foreground red)

    (omarchy-emacs--set-face
     'diff-changed
     :foreground yellow)

    ;; Header.
    (omarchy-emacs--set-face
     'header-line
     :foreground fg
     :background selection)

    (message "Omarchy colors applied to Emacs")))

(defun omarchy-emacs-reload ()
  "Read the current Omarchy palette and apply it."
  (interactive)

  (condition-case err
      (progn
        (setq omarchy-emacs--colors
              (omarchy-emacs--read-colors))

        (omarchy-emacs--apply-faces)

        (message
         "Emacs synchronized with Omarchy"))

    (error
     (message
      "Omarchy Emacs synchronization failed: %s"
      (error-message-string err)))))

(defun omarchy-emacs-enable ()
  "Enable Omarchy colors for Emacs."
  (interactive)

  (omarchy-emacs-reload)

  ;; Reapply after another Emacs theme is loaded.
  (add-hook
   'after-load-theme-hook
   #'omarchy-emacs-reload))

(provide 'omarchy-emacs)

;;; omarchy-emacs.el ends here
