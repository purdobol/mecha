;;; omni-omarchy-sources.el --- Consult Omni Omarchy source -*- lexical-binding: t -*-

;;; Commentary:
;; Consult Omni source for Omarchy commands.
;;
;; Parses ~/.local/share/omarchy/bin scripts.
;;
;; Uses:
;;   # omarchy:summary=
;;   # omarchy:examples=
;;
;;; Code:

(after! consult-omni

  (require 'consult-omni-sources)
  (require 'cl-lib)
  (require 'seq)
  (require 'subr-x)


  ;; --------------------------------------------------
  ;; Configuration
  ;; --------------------------------------------------

  (defconst my-omarchy-bin
    (expand-file-name "~/.local/share/omarchy/bin/"))

  (defvar my-omarchy-cache nil)



  ;; --------------------------------------------------
  ;; Cache
  ;; --------------------------------------------------

  (defun my-omarchy-refresh ()
    "Refresh Omarchy command cache."

    (interactive)

    (setq my-omarchy-cache nil)

    (message "Omarchy command cache refreshed"))



  ;; --------------------------------------------------
  ;; Metadata parser
  ;; --------------------------------------------------

  (defun my-omarchy-command-metadata (file key)

    (with-temp-buffer

      (insert-file-contents file)

      (when

          (re-search-forward

           (format "^# omarchy:%s=\\(.*\\)$" key)

           nil

           t)

        (string-trim

         (match-string 1)))))



  ;; --------------------------------------------------
  ;; Icons
  ;; --------------------------------------------------

  (defun my-omarchy-icon (command)

    (cond

     ((string-match-p "theme" command)
      "󰏘")


     ((string-match-p "waybar" command)
      "󰨚")


     ((string-match-p "hypr" command)
      "󰖯")


     ((string-match-p "capture" command)
      "󰄀")


     ((string-match-p "lock" command)
      "󰌾")


     ((string-match-p "update" command)
      "󰚰")


     ((string-match-p "install" command)
      "󰏖")


     (t
      "󰘳")))



  ;; --------------------------------------------------
  ;; Command database
  ;; --------------------------------------------------

  (defun my-omarchy-commands ()

    (unless my-omarchy-cache

      (setq my-omarchy-cache

            (mapcar

             (lambda (file)

               (let*

                   ((command

                     (file-name-nondirectory file))


                    (name

                     (capitalize

                      (replace-regexp-in-string

                       "-"

                       " "

                       (string-remove-prefix

                        "omarchy-"

                        command)))))


                 (list

                  :name name

                  :command command

                  :summary

                  (or

                   (my-omarchy-command-metadata
                    file
                    "summary")

                   "")


                  :examples

                  (or

                   (my-omarchy-command-metadata
                    file
                    "examples")

                   ""))))

             (directory-files

              my-omarchy-bin

              t

              "^omarchy-"))))


    my-omarchy-cache))



;; --------------------------------------------------
;; Candidate builder
;; --------------------------------------------------

(defun my-consult-omni-omarchy-builder
    (&optional input &key callback args &allow-other-keys)

  (let*

      ((parts

        (when input

          (split-string

           input

           ":"

           t)))


       (query

        (car parts))


       (arg-string

        (when (> (length parts) 1)

          (string-join

           (cdr parts)

           ":")))


       (commands

        (my-omarchy-commands))


       (filtered

        (if

            (and query

                 (> (length query) 0))

            (seq-filter

             (lambda (cmd)

               (string-match-p

                (regexp-quote query)

                (concat

                 (plist-get cmd :name)

                 " "

                 (plist-get cmd :summary)

                 " "

                 (plist-get cmd :examples))))

             commands)

          commands))


       (candidates

        (mapcar

         (lambda (cmd)

           (let*

               ((data

                 (copy-sequence cmd))


                (display

                 (concat

                  (my-omarchy-icon

                   (plist-get cmd :command))

                  " "

                  (plist-get cmd :name)


                  (when arg-string

                    (concat

                     " → "

                     arg-string)))))


             (when arg-string

               (plist-put

                data

                :args

                (condition-case nil

                    (mapcar

                     #'substring-no-properties

                     (split-string-and-unquote

                      arg-string))

                  (error

                   ;; While typing an incomplete quote,
                   ;; keep the raw argument as one argument.
                   (list

                    (substring-no-properties

                     arg-string))))))


             (propertize

              display

              'omarchy-command

              data

              'consult-omni-group

              "Omarchy")))

         filtered)))


    (when callback

      (funcall callback candidates))


    candidates))

;; --------------------------------------------------
;; Action
;; --------------------------------------------------

(defun my-consult-omni-omarchy-action (candidate)

  (let*

      ((data

        (get-text-property

         0

         'omarchy-command

         candidate))


       (command

        (plist-get data :command))


       (args

        (plist-get data :args)))


    (when command

      (apply

       #'call-process

       command

       nil

       "*omarchy-output*"

       t

       (or args '())))))

  ;; --------------------------------------------------
  ;; Annotation
  ;; --------------------------------------------------

(defun my-consult-omni-omarchy-annotate (candidate)

  (let*

      ((data

        (get-text-property

         0

         'omarchy-command

         candidate))


       (summary

        (plist-get data :summary))


       (examples

        (plist-get data :examples)))


    (concat

     (make-string

      2

      ?\s)


     (propertize

      (or summary "")

      'face

      'shadow)


     (when

         (and examples

              (> (length examples) 0))

       (concat

        "   "

        (propertize

         ":"

         'face

         'font-lock-keyword-face)

        (propertize

         examples

         'face

         'font-lock-comment-face))))))

  ;; --------------------------------------------------
  ;; Consult Omni source
  ;; --------------------------------------------------

(consult-omni-define-source

"Omarchy"

:narrow-char ?o

:type 'sync

:request
#'my-consult-omni-omarchy-builder

:on-callback
#'my-consult-omni-omarchy-action

:group
"Omarchy"

:annotate
#'my-consult-omni-omarchy-annotate

:sort t

:require-match nil)

  ;; --------------------------------------------------
  ;; Register source
  ;; --------------------------------------------------

  (setq consult-omni-local-sources

        (append

         (cl-remove

          "Omarchy"

          consult-omni-local-sources

          :test #'string=)


         '("Omarchy")))


(provide 'omni-omarchy-sources)

;;; omni-omarchy-sources.el ends here
