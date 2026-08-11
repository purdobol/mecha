;;; omni-denote-sources.el --- Consult Omni Denote source -*- lexical-binding: t -*-

;;; Commentary:
;; Consult-Omni source for Denote notes.
;;
;; Scans:
;; ~/Knowledge
;;
;; Uses Denote filename metadata only.
;; Does not open or parse note contents.
;;
;;  Denote Matra :P
;;
;;  Web = things I found
;;  Knowledge = things I kept/know
;;  Library = things I possess

;;
;;; Code:

(after! consult-omni

  (require 'consult-omni-sources)
  (require 'cl-lib)
  (require 'seq)


  ;; --------------------------------------------------
  ;; Denote filename parser
  ;; --------------------------------------------------

  (defun my-consult-omni-denote-files ()
    "Return Denote files from ~/Knowledge using filename metadata."

    (let ((directory (expand-file-name "~/Knowledge")))

      (when (file-directory-p directory)

        (mapcar
         (lambda (file)

           (let* ((filename
                   (file-name-nondirectory file))

                  (date
                   (when (string-match
                          "\\`\\([0-9T]+\\)--"
                          filename)
                     (match-string 1 filename)))

                  (title
                   (when (string-match
                          "--\\(.*?\\)__"
                          filename)
                     (replace-regexp-in-string
                      "-"
                      " "
                      (match-string 1 filename))))

                  (keywords
                   (when (string-match
                          "__\\(.*\\)\\.org\\'"
                          filename)
                     (split-string
                      (match-string 1 filename)
                      "_"
                      t))))

             (list
              :title (or title
                         (file-name-base filename))
              :file file
              :date date
              :keywords keywords)))

         (directory-files-recursively
          directory
          "\\.org\\'")))))


  ;; --------------------------------------------------
  ;; Candidate builder
  ;; --------------------------------------------------

(defun my-consult-omni-denote-builder
(&optional input &key callback &allow-other-keys)

"Build Consult Omni candidates from Denote files."

(let* ((all
        (my-consult-omni-denote-files))

       (filtered

        (if (and input
                 (> (length input) 0))

            (seq-filter

             (lambda (note)

               (string-match-p

                (regexp-quote input)

                (concat

                 (plist-get note :title)

                 " "

                 (mapconcat
                  #'identity
                  (or (plist-get note :keywords)
                      '())
                  " "))))

             all)

          all))


       (candidates

        (mapcar

         (lambda (note)

           (let ((title
                  (plist-get note :title))

                 (tags
                  (plist-get note :keywords)))


             (propertize

              (concat

               (propertize
                title
                'face
                'font-lock-keyword-face)

               (when tags

                 (concat

                  " "

                  (propertize

                   (concat
                    "#"
                    (string-join tags " #"))

                   'face
                   'font-lock-builtin-face))))

              'denote-note
              note

              'consult-omni-group
              "Denote")))

         filtered)))


  (when callback

    (funcall callback candidates))


  candidates))

  ;; --------------------------------------------------
  ;; Open action
  ;; --------------------------------------------------

  (defun my-consult-omni-denote-action (candidate)

  "Open Denote file using global consult file action."

  (let* ((note
          (get-text-property
           0
           'denote-note
           candidate))

         (file
          (plist-get note :file)))

    (when (and file
               (file-exists-p file))
      (my-consult-file-action file))))

  ;; --------------------------------------------------
  ;; Annotation
  ;; --------------------------------------------------

 (defun my-consult-omni-denote-annotate (candidate)

"Annotate Denote candidate."

(let* ((note
        (get-text-property
         0
         'denote-note
         candidate))

       (file
        (plist-get note :file)))

  (concat

   " "

   (propertize

    (file-name-nondirectory file)

    'face
    'shadow))))


  ;; --------------------------------------------------
  ;; Consult Omni source
  ;; --------------------------------------------------

  (consult-omni-define-source

   "Denote"

   :narrow-char ?d

   :type 'sync

   :request
   #'my-consult-omni-denote-builder

   :on-callback
   #'my-consult-omni-denote-action

   :group
   "Denote"

   :annotate
   #'my-consult-omni-denote-annotate

   :sort t

   :require-match nil)



  ;; --------------------------------------------------
  ;; Register source
  ;; --------------------------------------------------

  (setq consult-omni-local-sources

        (append

         (cl-remove
          "Denote"
          consult-omni-local-sources
          :test #'string=)

         '("Denote"))))


(provide 'omni-denote-sources)

;;; omni-denote-sources.el ends here
