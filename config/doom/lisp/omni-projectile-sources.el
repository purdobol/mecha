;;; omni-projectile-sources.el --- Consult Omni Projectile projects -*- lexical-binding: t; -*-

;;; Commentary:
;; Consult Omni source for Projectile projects.
;;
;; Uses Projectile's known project list.
;;
;; Features:
;; - project name search
;; - compact annotations
;; - opens project root
;;
;;; Code:

(after! consult-omni

  (require 'consult-omni-sources)
  (require 'projectile)
  (require 'cl-lib)
  (require 'seq)
  (require 'subr-x)


  ;; --------------------------------------------------
  ;; Collect projects
  ;; --------------------------------------------------

  (defun my-consult-omni-projectile-projects ()
  "Return known Projectile projects."

  (when (fboundp #'projectile-known-projects)

    ;; Make sure Projectile is initialized
    (projectile-mode +1)

    ;; Load saved projects if available
    (when (fboundp #'projectile-load-known-projects)
      (projectile-load-known-projects))

    ;; Convert project paths into Omni entries
    (mapcar

     (lambda (dir)

       (list
        :title
        (file-name-nondirectory
         (directory-file-name dir))

        :path
        dir))

     (projectile-known-projects))))

  ;; --------------------------------------------------
  ;; Builder
  ;; --------------------------------------------------

(defun my-consult-omni-projectile-builder
    (&optional input &key callback &allow-other-keys)

  "Build Projectile project candidates."

  (let* ((projects
          (my-consult-omni-projectile-projects))


         (filtered

          (if (and input
                   (not (string-empty-p input)))

              (seq-filter

               (lambda (project)

                 (string-match-p

                  (regexp-quote input)

                  (plist-get project :title)))

               projects)

            projects))


         (candidates

          (mapcar

           (lambda (project)

             (let* ((title
                     (plist-get project :title))

                    (icon
                     (if (require 'nerd-icons nil t)
                         (nerd-icons-mdicon
                          "nf-md-source_repository")
                       "󰉋"))

                    (display

                     (concat

                      icon
                      " "

                      (propertize

                       title

                       'face

                       'font-lock-warning-face))))


               (propertize

                display

                'projectile-project
                project

                'consult-omni-group
                "Projects")))

           filtered)))


    (when callback
      (funcall callback candidates))


    candidates))

  ;; --------------------------------------------------
  ;; Action
  ;; --------------------------------------------------

 (defun my-consult-omni-projectile-action
    (candidate)

  "Open Projectile project root in main Emacs frame."

  (let* ((project
          (get-text-property
           0
           'projectile-project
           candidate))

         (path
          (plist-get project :path)))

    (when (and path
               (file-directory-p path))

      (let* ((escaped-path
              (my/escape-elisp-string
               (expand-file-name path)))

             (cmd
              (my/consult-elisp-command
               (format
                "(dirvish \"%s\")"
                escaped-path))))

        (run-at-time
         0
         nil
         #'start-process
         "emacs-launcher"
         nil
         my/emacs-launcher-path
         cmd)))))

  ;; --------------------------------------------------
  ;; Annotation
  ;; --------------------------------------------------

  (defun my-consult-omni-projectile-annotate
      (candidate)

    "Annotate project candidate."

    (let* ((project

            (get-text-property

             0

             'projectile-project

             candidate))


           (path

            (plist-get project :path)))


      (concat

       " "

       (propertize

        path

        'face

        'shadow))))


  ;; --------------------------------------------------
  ;; Consult Omni source
  ;; --------------------------------------------------

  (consult-omni-define-source

   "Projectile"

   :narrow-char ?p

   :type 'sync

   :request
   #'my-consult-omni-projectile-builder

   :on-callback
   #'my-consult-omni-projectile-action

   :group
   "Projects"

   :annotate
   #'my-consult-omni-projectile-annotate

   :sort t

   :require-match nil)


  ;; --------------------------------------------------
  ;; Register source
  ;; --------------------------------------------------

  (setq consult-omni-local-sources

        (append

         (cl-remove

          "Projectile"

          consult-omni-local-sources

          :test #'string=)

         '("Projectile"))))


(provide 'omni-projectile-sources)

;;; omni-projectile-sources.el ends here
