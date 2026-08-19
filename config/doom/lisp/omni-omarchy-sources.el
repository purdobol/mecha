;;; omni-omarchy-sources.el --- Consult Omni Omarchy source -*- lexical-binding: t -*-

;;; Commentary:
;; Consult Omni source for Omarchy commands.
;;
;; Uses Omarchy's v4 machine-readable command registry:
;;
;;   omarchy commands --json
;;
;; Only user-facing command groups are exposed by default.
;;
;; Usage:
;;
;;   o <query>
;;   o <query>:<arguments>
;;
;; Examples:
;;
;;   o theme
;;   o system lock
;;   o capture screenshot
;;   o theme set:catppuccin
;;
;;; Code:

(after! consult-omni

  (require 'consult-omni-sources)
  (require 'cl-lib)
  (require 'seq)
  (require 'subr-x)
  (require 'json)


  ;; --------------------------------------------------
  ;; Configuration
  ;; --------------------------------------------------

  (defconst my-omarchy-program
    "omarchy"
    "Omarchy CLI executable.")


  ;; User-facing Omarchy command groups to expose.
  ;;
  ;; Add/remove groups here without touching the rest
  ;; of the source.
  ;;
  ;; These correspond to the documented Omarchy CLI
  ;; groups such as:
  ;;
  ;;   omarchy theme ...
  ;;   omarchy refresh ...
  ;;   omarchy restart ...
  ;;   omarchy toggle ...
  ;;   omarchy bar ...
  ;;   omarchy plugin ...
  ;;   omarchy hook ...
  ;;   omarchy install ...
  ;;   omarchy launch ...
  ;;   omarchy capture ...
  ;;   omarchy reminder ...
  ;;   omarchy pkg ...
  ;;   omarchy setup ...
  ;;
  ;; System/font/menu/version/update are included separately
  ;; because they are useful standalone commands.

  (defconst my-omarchy-command-groups

    '("theme"
      "refresh"
      "restart"
      "toggle"
      "bar"
      "plugin"
      "hook"
      "install"
      "launch"
      "capture"
      "reminder"
      "pkg"
      "setup"
      "system"
      "font"
      "menu"
      "update")

    "Omarchy command groups exposed through Consult Omni.")


  ;; Standalone commands that do not necessarily have one
  ;; of the groups above.

  (defconst my-omarchy-standalone-commands

    '("omarchy"
      "omarchy update"
      "omarchy version")

    "Explicit standalone Omarchy commands to expose.")


  (defvar my-omarchy-cache nil
    "Cached Omarchy command database.")



  ;; --------------------------------------------------
  ;; Cache
  ;; --------------------------------------------------

  (defun my-omarchy-refresh ()
    "Refresh Omarchy command cache."

    (interactive)

    (setq my-omarchy-cache nil)

    (message "Omarchy command cache refreshed"))



  ;; --------------------------------------------------
  ;; JSON helpers
  ;; --------------------------------------------------

  (defun my-omarchy-json-get (object key)
    "Get KEY from JSON OBJECT."

    (cond

     ((listp object)

      (or

       (cdr (assoc
             key
             object))

       (cdr (assoc
             (intern key)
             object))))

     ((hash-table-p object)

      (or

       (gethash
        key
        object)

       (gethash
        (intern key)
        object)))

     (t
      nil)))


  (defun my-omarchy-string (value)
    "Convert VALUE to a displayable string."

    (cond

     ((null value)
      "")

     ((stringp value)
      value)

     ((listp value)

      (mapconcat
       #'my-omarchy-string
       value
       " "))

     (t
      (format "%s" value))))



  ;; --------------------------------------------------
  ;; Command filtering
  ;; --------------------------------------------------

  (defun my-omarchy-command-user-facing-p (route)
    "Return non-nil when ROUTE is useful in the launcher."

    (or

     ;; Explicit standalone command.

     (member
      route
      my-omarchy-standalone-commands)


     ;; Grouped command.

     (let* ((without-prefix

             (string-remove-prefix
              "omarchy "
              route))

            (group

             (car
              (split-string
               without-prefix
               "[[:space:]]+"
               t))))

       (member
        group
        my-omarchy-command-groups))))


  ;; --------------------------------------------------
  ;; Omarchy command registry
  ;; --------------------------------------------------

  (defun my-omarchy-command-registry ()
    "Return Omarchy commands from `omarchy commands --json'."

    (with-temp-buffer

      (let ((exit-code

             (call-process
              my-omarchy-program
              nil
              t
              nil
              "commands"
              "--json")))

        (unless
            (zerop exit-code)

          (error
           "Omarchy command discovery failed (exit code %s)"
           exit-code))


        (goto-char
         (point-min))


        (condition-case err

            (let* ((json

                    (json-parse-buffer
                     :object-type 'alist
                     :array-type 'list
                     :null-object nil
                     :false-object nil))

                   (commands

                    (my-omarchy-json-get
                     json
                     "commands")))


              (unless
                  (listp commands)

                (error
                 "Unexpected output from `omarchy commands --json'"))


              commands)


          (error

           (error
            "Could not parse Omarchy command JSON: %s"
            (error-message-string
             err)))))))



  ;; --------------------------------------------------
  ;; Icons
  ;; --------------------------------------------------

  (defun my-omarchy-icon (command)

    (cond

     ((string-match-p
       "theme"
       command)
      "󰏘")

     ((string-match-p
       "waybar\\|bar"
       command)
      "󰨚")

     ((string-match-p
       "hypr"
       command)
      "󰖯")

     ((string-match-p
       "capture\\|screenshot\\|record"
       command)
      "󰄀")

     ((string-match-p
       "lock"
       command)
      "󰌾")

     ((string-match-p
       "update"
       command)
      "󰚰")

     ((string-match-p
       "install\\|pkg"
       command)
      "󰏖")

     ((string-match-p
       "plugin"
       command)
      "󰏗")

     ((string-match-p
       "launch"
       command)
      "󰆍")

     ((string-match-p
       "restart\\|refresh"
       command)
      "󰑓")

     ((string-match-p
       "toggle"
       command)
      "󰔡")

     ((string-match-p
       "font"
       command)
      "󰛖")

     ((string-match-p
       "system"
       command)
      "󰒓")

     (t
      "󰘳")))



  ;; --------------------------------------------------
  ;; Command name
  ;; --------------------------------------------------

  (defun my-omarchy-command-name (route)

    (capitalize

     (replace-regexp-in-string

      "-"

      " "

      (string-remove-prefix
       "omarchy "
       route))))



  ;; --------------------------------------------------
  ;; Command database
  ;; --------------------------------------------------

  (defun my-omarchy-commands ()

    (unless my-omarchy-cache

      (setq my-omarchy-cache

            (seq-filter

             #'identity

             (mapcar

              (lambda (command)

                (let*

                    ((binary

                      (my-omarchy-string

                       (my-omarchy-json-get
                        command
                        "binary")))

                     (route

                      (my-omarchy-string

                       (my-omarchy-json-get
                        command
                        "route")))

                     (summary

                      (my-omarchy-string

                       (my-omarchy-json-get
                        command
                        "summary")))

                     (args

                      (my-omarchy-string

                       (my-omarchy-json-get
                        command
                        "args")))

                     (aliases

                      (my-omarchy-json-get
                       command
                       "aliases")))


                  ;; Ignore commands that are not useful
                  ;; in the launcher.

                  (when

                      (and
                       (> (length route) 0)

                       (my-omarchy-command-user-facing-p
                        route))

                    (list

                     :name
                     (my-omarchy-command-name
                      route)

                     :command
                     binary

                     :route
                     route

                     :summary
                     summary

                     :args
                     args

                     :aliases
                     aliases))))


              (my-omarchy-command-registry)))))


    my-omarchy-cache)



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

                   (plist-get
                    cmd
                    :name)

                   " "

                   (plist-get
                    cmd
                    :route)

                   " "

                   (plist-get
                    cmd
                    :summary)

                   " "

                   (plist-get
                    cmd
                    :args)

                   " "

                   (my-omarchy-string
                    (plist-get
                     cmd
                     :aliases)))))

               commands)

            commands))


         (candidates

          (mapcar

           (lambda (cmd)

             (let*

                 ((data
                   (copy-sequence
                    cmd))

                  (route
                   (plist-get
                    cmd
                    :route))

                  (display

                   (concat

                    (my-omarchy-icon
                     route)

                    " "

                    (plist-get
                     cmd
                     :name)

                    (when arg-string

                      (concat
                       " → "
                       arg-string)))))


               ;; --------------------------------------------------
               ;; Parse user arguments
               ;; --------------------------------------------------

               (when arg-string

                 (plist-put

                  data

                  :input-args

                  (condition-case nil

                      (mapcar

                       #'substring-no-properties

                       (split-string-and-unquote
                        arg-string))

                    (error

                     ;; Keep incomplete quoted input as
                     ;; one argument while typing.

                     (list

                      (substring-no-properties
                       arg-string))))))


               ;; --------------------------------------------------
               ;; Canonical v4 invocation
               ;; --------------------------------------------------
               ;;
               ;; The route already contains "omarchy".
               ;;
               ;; Example:
               ;;
               ;;   omarchy system lock
               ;;
               ;; becomes:
               ;;
               ;;   ("omarchy" "system" "lock")
               ;;
               ;; --------------------------------------------------

               (plist-put

                data

                :invocation

                (split-string
                 route
                 "[[:space:]]+"
                 t))


               ;; --------------------------------------------------
               ;; Candidate
               ;; --------------------------------------------------

               (propertize

                display

                'omarchy-command
                data

                'consult-omni-group
                "Omarchy")))

           filtered)))


      (when callback

        (funcall
         callback
         candidates))


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

         (invocation

          (plist-get
           data
           :invocation))

         (args

          (plist-get
           data
           :input-args)))


      (when invocation

        ;; Example:
        ;;
        ;; ("omarchy" "system" "lock")
        ;;
        ;; executes:
        ;;
        ;;   omarchy system lock

        (apply

         #'call-process

         (car invocation)

         nil

         "*omarchy-output*"

         t

         (append

          (cdr invocation)

          (or
           args
           '()))))))



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

          (plist-get
           data
           :summary))

         (args

          (plist-get
           data
           :args)))


      (concat

       (make-string
        2
        ?\s)

       (when
           (> (length summary) 0)

         (propertize
          summary
          'face
          'shadow))

       (when

           (and
            args
            (> (length args) 0))

         (concat

          "   "

          (propertize
           args
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

         '("Omarchy"))))


(provide 'omni-omarchy-sources)

;;; omni-omarchy-sources.el ends here
