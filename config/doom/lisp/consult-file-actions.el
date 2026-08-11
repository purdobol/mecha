;;; consult-file-actions.el --- Global file open logic -*- lexical-binding: t; -*-

;;; Commentary:
;; Customizes Consult's file-selection action.
;;
;; Files that Emacs should not handle directly (large files, media,
;; documents, archives, etc.) are opened with the system application.
;;
;; Directories are opened through Dirvish, while normal files are opened
;; in Emacs. Both Emacs actions are launched through the external
;; emacs-launcher so they open in the dedicated "omni" perspective.

;;; Code:

;;; ---------------------------------------------------------
;;; Configuration
;;; ---------------------------------------------------------

(defvar my-consult-large-file-threshold
  (* 100 1024 1024)
  "Files larger than this threshold open externally.")

(defvar my/emacs-launcher-path
  (expand-file-name "~/.config/hypr/scripts/emacs-launcher")
  "Absolute path to the Emacs launcher script.")


;;; ---------------------------------------------------------
;;; Helpers
;;; ---------------------------------------------------------

(defun my/escape-elisp-string (s)
  "Escape S for use in an Elisp string."
  (replace-regexp-in-string "\"" "\\\"" s))

(defun my/consult-elisp-command (elisp)
  "Wrap ELISP in the Omni workspace launcher."
  (format
   "(progn
(require 'persp-mode)

  (unless (persp-with-name-exists-p \"omni\")
    (persp-add-new \"omni\"))

  (persp-switch \"omni\")

  (delete-other-windows)

  %s)"
   elisp))

(defun my/file-extension (file)
  "Return the lowercase extension of FILE."
  (downcase
   (or (file-name-extension file) "")))

(defun my/external-file-p (file)
  "Return non-nil if FILE should be opened externally."
  (let ((ext (my/file-extension file)))
    (or
     ;; Avoid loading very large files into Emacs.
     (> (or (nth 7 (file-attributes file)) 0)
        my-consult-large-file-threshold)

     ;; Documents handled by dedicated external applications.
     (member ext
             '("pdf"
               "epub"
               "djvu"))

     ;; Images.
     (member ext
             '("png"
               "jpg"
               "jpeg"
               "gif"
               "webp"
               "svg"
               "bmp"
               "tiff"))

     ;; Video.
     (member ext
             '("mp4"
               "mkv"
               "avi"
               "mov"
               "webm"
               "m4v"))

     ;; Audio.
     (member ext
             '("mp3"
               "flac"
               "wav"
               "ogg"
               "m4a"))

     ;; Disk images.
     (member ext
             '("iso"
               "img"))

     ;; Archives are opened externally rather than being handled
     ;; by Emacs or Dirvish as regular files.
     (member ext
             '("zip"
               "tar"
               "gz"
               "tgz"
               "bz2"
               "xz"
               "7z"
               "rar"
               "zst")))))


;;; ---------------------------------------------------------
;;; Main file dispatcher
;;; ---------------------------------------------------------

(defun my-consult-file-action (file)
  "Open FILE intelligently through the Omni file-action system."
  (let ((file (expand-file-name file)))
    (cond

     ;; Files that should be handled by an external application.
     ((my/external-file-p file)
      (start-process
       "xdg-open"
       nil
       "xdg-open"
       file)
      nil)

     ;; Directories are opened with Dirvish inside the Omni perspective.
     ((file-directory-p file)
      (let ((cmd
             (my/consult-elisp-command
              (format
               "(dirvish \"%s\")"
               (my/escape-elisp-string file)))))
        (run-at-time
         0
         nil
         #'start-process
         "emacs-launcher"
         nil
         my/emacs-launcher-path
         cmd))
      nil)

     ;; Normal files are opened with find-file inside the Omni perspective.
     (t
      (let ((cmd
             (my/consult-elisp-command
              (format
               "(find-file \"%s\")"
               (my/escape-elisp-string file)))))
        (run-at-time
         0
         nil
         #'start-process
         "emacs-launcher"
         nil
         my/emacs-launcher-path
         cmd))))))


;;; ---------------------------------------------------------
;;; Consult override
;;; ---------------------------------------------------------

;; Replace Consult's default file action with the dispatcher above.
(with-eval-after-load 'consult
  (advice-add
   'consult--file-action
   :override
   #'my-consult-file-action))


(provide 'consult-file-actions)

;;; consult-file-actions.el ends here
