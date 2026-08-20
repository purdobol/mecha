;;; omni-local.el --- Local Consult-Omni search and floating frame -*- lexical-binding: t; -*-

;;; Commentary:
;; Defines the local Omni search experience:
;;
;; 1. Configures fd for fast personal-file searching.
;; 2. Defines the sources used by consult-omni-local.
;; 3. Provides the native floating-frame UI.
;; 4. Exposes my/omni-local-real as the frame-based entry point.
;; 5. Allows M-x inside the Omni floating frame to launch commands
;;    after the Omni/Consult recursive edit has completely exited.
;;
;; Loading of this file is handled externally by the Omni lazy-loader.

;;; Code:

;; --------------------------------------------------
;; fd configuration
;; --------------------------------------------------

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

(defvar my/omni-frame nil
  "The current Omni floating frame.")

(defvar my/omni-buffer "*omni*"
  "Buffer used by the Omni floating frame.")

(defvar my/omni-current-mode nil
  "Current Omni mode.")

;; --------------------------------------------------
;; M-x state
;; --------------------------------------------------

(defvar my/omni--m-x-active nil
  "Non-nil while M-x is active inside the Omni frame.")

;; --------------------------------------------------
;; Find main Emacs frame
;; --------------------------------------------------

(defun my/omni--main-frame ()
  "Return the normal Emacs frame, excluding the Omni frame."
  (seq-find
   (lambda (frame)
     (and (frame-live-p frame)
          (not (eq frame my/omni-frame))
          (not (string= (frame-parameter frame 'name)
                        "omni"))))
   (frame-list)))

;; --------------------------------------------------
;; Frame creation
;; --------------------------------------------------

(defun my/omni--make-frame (width height)
  "Create the floating Omni frame."
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

(defun my/omni-render-header (title subtitle)
  "Render the centered Omni header."
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
;; M-x command interception
;; --------------------------------------------------
;;
;; M-x itself is not replaced.
;;
;; While M-x is active inside the Omni frame, command-execute
;; captures the selected command and throws a DISTINCT tagged
;; value out through the Omni/Consult recursive-edit stack.
;;
;; The tag is important:
;;
;;   (:m-x-command COMMAND)
;;
;; Normal Omni results are NOT tagged this way, so they are
;; never accidentally treated as M-x commands.
;;
;; my/omni-launch catches the tagged command, lets Omni
;; completely unwind and close, and then executes the command.
;;
;; Normal command execution outside M-x is untouched.

(defun my/omni--command-execute-advice
    (orig-fn command &rest args)
  "Capture a command selected by M-x inside the Omni frame."
  (if (and my/omni--m-x-active
           (frame-live-p my/omni-frame)
           (eq (selected-frame) my/omni-frame)
           (commandp command))
      ;; IMPORTANT:
      ;; Tag this value so normal Omni results cannot be
      ;; mistaken for an M-x command.
      (throw 'my/omni-command
             (list :m-x-command command))
    (apply orig-fn command args)))

(defun my/omni--execute-extended-command-advice
    (orig-fn &rest args)
  "Mark M-x as active while it runs inside Omni."
  (if (and (frame-live-p my/omni-frame)
           (eq (selected-frame) my/omni-frame))
      (let ((my/omni--m-x-active t))
        (apply orig-fn args))
    (apply orig-fn args)))

;; Install the interception advice.
(advice-add #'execute-extended-command
            :around
            #'my/omni--execute-extended-command-advice)

(advice-add #'command-execute
            :around
            #'my/omni--command-execute-advice)

;; --------------------------------------------------
;; Core frame launcher
;; --------------------------------------------------

(defun my/omni-launch (mode width height fn title subtitle)
  "Launch an Omni search in a floating frame."
  (setq my/omni-current-mode mode)

  ;; Close an existing Omni frame.
  (when (frame-live-p my/omni-frame)
    (delete-frame my/omni-frame)
    (setq my/omni-frame nil))

  ;; Create the floating frame.
  (setq my/omni-frame
        (my/omni--make-frame width height))

  ;; Holds the tagged M-x escape value, if M-x was used.
  ;;
  ;; Normal Omni results may also be returned by FN, but they
  ;; will NOT have the :m-x-command tag and therefore will not
  ;; be executed here.
  (let (pending-command)

    ;; Everything inside this block runs in the Omni frame.
    (with-selected-frame my/omni-frame
      (select-frame-set-input-focus my/omni-frame)

      (let ((buf (get-buffer-create my/omni-buffer)))
        (switch-to-buffer buf)

        ;; Keep the Omni frame focused on the search interface.
        (setq-local mode-line-format nil)
        (setq-local header-line-format nil)
        (setq-local cursor-type nil)

        ;; Render header.
        (my/omni-render-header title subtitle)

        ;; Run Omni.
        ;;
        ;; Normal Omni results return normally.
        ;;
        ;; M-x throws:
        ;;
        ;;   (:m-x-command COMMAND)
        ;;
        ;; which escapes this catch.
        (unwind-protect
            (setq pending-command
                  (catch 'my/omni-command
                    (funcall fn)))

          ;; Clean up the floating frame.
          (when (frame-live-p my/omni-frame)
            (delete-frame my/omni-frame))

          (setq my/omni-frame nil))))

    ;; --------------------------------------------------
    ;; M-x only
    ;; --------------------------------------------------
    ;;
    ;; Only a value explicitly tagged :m-x-command gets here.
    ;;
    ;; This prevents normal Omni results such as Apps,
    ;; Projectile, fd, OrgBookmarks, etc. from being treated
    ;; as Emacs commands.
    (when (and (consp pending-command)
               (eq (car pending-command) :m-x-command))

      (let ((command (cadr pending-command))
            (main-frame
             (my/omni--main-frame)))

        ;; Focus the main Emacs frame.
        ;;
        ;; This is what allows the window manager to follow
        ;; Emacs to its workspace in your current setup.
        (when (frame-live-p main-frame)
          (select-frame-set-input-focus main-frame))

        ;; Execute the M-x command interactively.
        (when (commandp command)
          (call-interactively command))))))

;; --------------------------------------------------
;; Public local launcher
;; --------------------------------------------------

(defun my/omni-local-real ()
  "Launch the local Omni search in a floating frame."
  (interactive)

  (my/omni-launch
   'local
   110
   28
   #'consult-omni-local
   "omni.local"
   "/ indexing / memory / context / execution /"))

(provide 'omni-local)

;;; omni-local.el ends here
