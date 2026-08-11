;;; workspaces-setup.el --- Doom modeline + isolated workspaces -*- lexical-binding: t -*-

;;; Commentary:
;; Adds Lightemacs-inspired isolated workspace behavior on top of
;; Doom's built-in workspaces module.
;;
;; Features:
;; - Fresh workspace starts with clean window layout
;; - Empty workspaces open a scratch buffer
;; - Custom Doom modeline workspace display
;;
;;; Code:


;; ----------------------------
;; Isolated workspaces
;; ----------------------------

(after! persp-mode

  ;; Do not automatically modify layouts when switching projects.
  ;; Doom still manages workspace persistence.
  (setq +workspaces-on-switch-project-behavior nil)


  ;; Function to initialize a new workspace layout
  (defun my/persp-new-isolated-layout ()
    "Ensure new workspace has an independent clean layout."
    (delete-other-windows)
    (switch-to-buffer (get-buffer-create "*scratch*")))


  ;; Run after switching workspace.
  ;; If the workspace has no buffers, create a clean layout.
  (add-hook 'persp-after-switch-functions
            (lambda (&rest _)
              (when-let ((current (get-frame-persp)))
                (when (null (persp-buffer-list current))
                  (my/persp-new-isolated-layout)))))


  ;; Create a completely fresh workspace interactively.
  (defun my/create-fresh-workspace (name)
    "Create a new isolated workspace called NAME."
    (interactive "sWorkspace name: ")
    (let ((ws (persp-add-new (generate-new-buffer-name name))))
      (persp-frame-switch ws)
      (my/persp-new-isolated-layout))))


;; ----------------------------
;; Doom modeline workspace display
;; ----------------------------

(after! doom-modeline

  (defun my/doom-modeline-persp-format ()
    "Return workspace number and name for Doom modeline."
    (when (bound-and-true-p persp-mode)
      (when-let ((current (get-frame-persp)))
        (let* ((name (persp-name current))
               (num  (persp-index (persp-get-by-name name)))
               (icon "🗂"))
          (format " %s[%s:%s]" icon num name)))))


  ;; Tell Doom modeline to use our formatter.
  (setq doom-modeline-persp-name-function #'my/doom-modeline-persp-format
        doom-modeline-persp-name t
        doom-modeline-persp-name-only nil))


(provide 'workspaces-setup)

;;; workspaces-setup.el ends here
