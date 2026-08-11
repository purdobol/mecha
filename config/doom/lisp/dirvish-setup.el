;; lisp/dirvish-setup.el -*- lexical-binding: t; -*-

(after! dirvish

  ;; =========================================================
  ;; Preview configuration
  ;; =========================================================

  (setq dirvish-preview-dispatchers
        '(image
          archive
          gif
          video
          pdf))

  (setq dirvish-attributes
        '(vc-state
          subtree-state
          nerd-icons
          collapse
          file-size
          file-time))

  (setq dirvish-preview-image-width 40)


  ;; =========================================================
  ;; Smart file opening
  ;; =========================================================
  ;;
  ;; This dispatcher is shared by Dired and Dirvish.
  ;;
  ;; Directory              -> normal Dired/Dirvish navigation
  ;; External file types    -> xdg-open
  ;; Large files             -> xdg-open
  ;; Everything else        -> find-file
  ;;
  ;; Therefore RET behaves consistently in both Dired and
  ;; Dirvish.

  (defun my/file-extension (file)
    "Return the lowercase extension of FILE."
    (downcase
     (or (file-name-extension file) "")))


  (defun my/external-file-p (file)
    "Return non-nil if FILE should be opened externally."

    (let ((ext (my/file-extension file)))

      (or
       ;; -----------------------------------------------------
       ;; Large files
       ;; -----------------------------------------------------

       (> (or (nth 7 (file-attributes file)) 0)
          my-consult-large-file-threshold)


       ;; -----------------------------------------------------
       ;; Documents
       ;; -----------------------------------------------------

       (member ext
               '("pdf"
                 "epub"
                 "djvu"))


       ;; -----------------------------------------------------
       ;; Images
       ;; -----------------------------------------------------

       (member ext
               '("png"
                 "jpg"
                 "jpeg"
                 "gif"
                 "webp"
                 "svg"
                 "bmp"
                 "tiff"))


       ;; -----------------------------------------------------
       ;; Video
       ;; -----------------------------------------------------

       (member ext
               '("mp4"
                 "mkv"
                 "avi"
                 "mov"
                 "webm"
                 "m4v"))


       ;; -----------------------------------------------------
       ;; Audio
       ;; -----------------------------------------------------

       (member ext
               '("mp3"
                 "flac"
                 "wav"
                 "ogg"
                 "m4a"))


       ;; -----------------------------------------------------
       ;; Disk images
       ;; -----------------------------------------------------

       (member ext
               '("iso"
                 "img"))


       ;; -----------------------------------------------------
       ;; Archives
       ;; -----------------------------------------------------

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


  ;; ---------------------------------------------------------
  ;; Open externally
  ;; ---------------------------------------------------------

  (defun my/open-file-external (file)
    "Open FILE using the system's default application."

    (start-process
     "xdg-open"
     nil
     "xdg-open"
     (expand-file-name file)))


  ;; ---------------------------------------------------------
  ;; Smart RET dispatcher
  ;; ---------------------------------------------------------

  (defun my/dired-dirvish-smart-open ()
    "Open the file or directory at point intelligently.

Directories are opened normally.

Files configured as external are opened with `xdg-open`.

All other files are opened with `find-file`."

    (interactive)

    (let ((file (ignore-errors
                  (dired-get-file-for-visit))))

      (when file

        (setq file (expand-file-name file))

        (cond

         ;; --------------------------------------------------
         ;; Directory
         ;; --------------------------------------------------

         ((file-directory-p file)

          ;; Use the normal command for whichever Dired-like
          ;; buffer we are currently in.
          (dired-find-file))


         ;; --------------------------------------------------
         ;; External file
         ;; --------------------------------------------------

         ((my/external-file-p file)

          (my/open-file-external file))


         ;; --------------------------------------------------
         ;; Normal Emacs file
         ;; --------------------------------------------------

         (t

          (find-file file))))))


  ;; =========================================================
  ;; Explicit external opening
  ;; =========================================================
  ;;
  ;; C-c o always opens the file at point externally,
  ;; regardless of extension.

  (defun my/dired-dirvish-open-external ()
    "Always open the file at point externally.

Directories are opened normally."

    (interactive)

    (let ((file (ignore-errors
                  (dired-get-file-for-visit))))

      (when file

        (setq file (expand-file-name file))

        (if (file-directory-p file)

            (dired-find-file)

          (my/open-file-external file)))))


  ;; =========================================================
  ;; Dired
  ;; =========================================================

  ;; RET:
  ;;   directory -> navigate
  ;;   PDF/image/video/etc -> xdg-open
  ;;   normal file -> find-file
  ;;
  ;; C-c o:
  ;;   always xdg-open files

  (with-eval-after-load 'dired
    (define-key dired-mode-map
                (kbd "RET")
                #'my/dired-dirvish-smart-open)

    (define-key dired-mode-map
                (kbd "C-c o")
                #'my/dired-dirvish-open-external))


  ;; =========================================================
  ;; Dirvish
  ;; =========================================================

  ;; RET:
  ;;   directory -> navigate
  ;;   PDF/image/video/etc -> xdg-open
  ;;   normal file -> find-file
  ;;
  ;; C-c o:
  ;;   always xdg-open files

  (define-key dirvish-mode-map
              (kbd "RET")
              #'my/dired-dirvish-smart-open)

  (define-key dirvish-mode-map
              (kbd "C-c o")
              #'my/dired-dirvish-open-external)


  ;; =========================================================
  ;; Quick access
  ;; =========================================================

  (defun my/dirvish-quick-access-simple ()
    "Simple Quick Access menu for Dirvish."

    (interactive)

    (let* ((choices
            '(("Home" . "~")
              ("Root" . "/")
              ("Downloads" . "~/Downloads")
              ("Documents" . "~/Documents")
              ("Pictures" . "~/Pictures")
              ("Videos" . "~/Videos")
              ("Music" . "~/Music")
              ("Trash" . "~/.local/share/Trash/files")
              ("Media Drives" . "/run/media/")
              ("NAS" . "/mnt/nas/")))

           (selection
            (completing-read
             "Open location: "
             (mapcar #'car choices)
             nil
             t))

           (path
            (cdr (assoc selection choices))))

      (when path
        (dirvish (expand-file-name path)))))


  ;; Global quick access
  (global-set-key
   (kbd "C-c C-q")
   #'my/dirvish-quick-access-simple))


(provide 'dirvish-setup)

;;; dirvish-setup.el ends here
