;;; org-browser.el --- Org notes browser -*- lexical-binding: t; -*-

;;; Commentary:
;; Two-pane Org notes browser.
;;
;; Features:
;; - Browse ~/org/notes/*.org
;; - Preview selected notes
;; - Show timestamps
;; - Show categories
;; - Show tags
;; - Add notes through org-capture
;; - Mark/delete notes
;; - Consult filtering
;;
;;
;; Standalone Emacs version (no Doom dependencies).

;;; Code:

(require 'org)
(require 'org-setup)
(require 'tabulated-list)
(require 'cl-lib)


(defgroup my-org-browser nil
  "Org notes browser."
  :group 'org)


(cl-defstruct my-org-browser-note
  title
  file
  position
  timestamp
  tags
  category
  source
  promoted
  denote-file)


(defcustom my-org-browser-directory
  "~/org/notes/"
  "Directory containing Org note files."

  :type 'directory
  :group 'my-org-browser)

(defcustom my-org-browser-web-directory
  "~/org/web/"
  "Directory containing Org web files."

  :type 'directory
  :group 'my-org-browser)


(defcustom my-org-browser-knowledge-directory
  "~/Knowledge/"
  "Directory for permanent Denote notes."

  :type 'directory
  :group 'my-org-browser)


(defcustom my-org-browser-knowledge-web-directory
  "~/Knowledge/Web/"
  "Directory for promoted web notes."

  :type 'directory
  :group 'my-org-browser)

(defvar my-org-browser--alist nil
  "Cached notes list.

Each entry:

(TITLE FILE POSITION TIME TAGS CATEGORY)")



(defvar my-org-browser-preview-buffer
  "*Org Browser Preview*"
  "Preview buffer name.")



(defvar my-org-browser--marked nil
  "Marked notes list.

Each entry is:

(FILE . POSITION)")

(defvar my-org-browser-collectors
  '((notes . my-org-browser--collect-notes)
    (web . my-org-browser--collect-web)
    (tasks . my-org-browser--collect-tasks)
    (bookmarks . my-org-browser--collect-bookmarks)
    (contacts . my-org-browser--collect-contacts)))

(defvar my-org-browser-current-source 'notes
  "Current browser source.")



;; --------------------------------------------------
;; Faces
;; --------------------------------------------------

(defface my-org-browser-title-face
  '((t (:weight bold
                :inherit font-lock-function-name-face)))
  "Title face."
  :group 'my-org--browser)



(defface my-org-browser-time-face
  '((t (:inherit font-lock-comment-face)))
  "Timestamp face."
  :group 'my-org--browser)



(defface my-org-browser-category-face
  '((t (:inherit font-lock-constant-face)))
  "Category face."
  :group 'my-org-browser)



(defface my-org-browser-tags-face
  '((t (:inherit font-lock-keyword-face)))
  "Tags face."
  :group 'my-org-browser)



;; --------------------------------------------------
;; Timestamp parser
;; --------------------------------------------------

(defun my-org-browser--time-from-string (time-string)
  "Return time object from Org timestamp string."

  (when
      (string-match
       "\\[\\([0-9]+-[0-9]+-[0-9]+ [^]]+\\)\\]"
       time-string)

    (ignore-errors
      (date-to-time
       (match-string 1 time-string)))))





;; --------------------------------------------------
;; Generic Org headline collector
;; --------------------------------------------------

;; (defun my-org-browser--collect-org-headlines (directory source)
;;   "Collect level 2 Org headlines from DIRECTORY.
;;
;; SOURCE identifies where the entries came from."
;;
;;   (let ((files
;;          (directory-files-recursively
;;           directory
;;           "\\.org$"))
;;
;;         (headings nil))
;;
;;
;;     (dolist (file files)
;;
;;       (with-temp-buffer
;;
;;         (insert-file-contents file)
;;
;;         (org-mode)
;;
;;
;;         (org-element-map
;;             (org-element-parse-buffer 'headline)
;;             'headline
;;
;;
;;           (lambda (headline)
;;
;;             (when
;;                 (= (org-element-property
;;                     :level
;;                     headline)
;;
;;                    2)
;;
;;
;;               (let* ((title
;;                       (org-element-property
;;                        :title
;;                        headline))
;;
;;                      (position
;;                       (org-element-property
;;                        :begin
;;                        headline))
;;
;;                      (subtree
;;                       (buffer-substring-no-properties
;;                        position
;;                        (org-element-property
;;                         :end
;;                         headline))))
;;
;;                 ;; collect timestamps
;;
;;                 (let ((timestamps nil))
;;
;;                   (with-temp-buffer
;;
;;                     (insert subtree)
;;
;;                     (goto-char
;;                      (point-min))
;;
;;                     (while
;;                         (re-search-forward
;;                          "\\(\\[[0-9]+-[0-9]+-[0-9]+[^]]*\\]\\)"
;;                          nil
;;                          t)
;;
;;                       (push
;;                        (match-string 1)
;;                        timestamps)))
;;
;;
;;                   (push
;;
;;                    (make-my-org-browser-note
;;                     :title title
;;                     :file file
;;                     :position position
;;                     :timestamp
;;                     (if timestamps
;;
;;                         (mapconcat
;;                          #'identity
;;                          (reverse timestamps)
;;                          ", ")
;;
;;                       "—")
;;
;;                     :tags
;;                     (or
;;                      (org-element-property
;;                       :tags
;;                       headline)
;;
;;                      '())
;;
;;                     :category
;;                     (file-name-base file)
;;
;;                     :source source
;;                     :promoted
;;                     (my-org-browser--note-promoted-p)
;;
;;                     :denote-file
;;                     (org-entry-get nil "DENOTE"))
;;
;;                    headings))))))))
;;
;;
;;     (nreverse headings)))


(defun my-org-browser--collect-org-headlines (directory source)
  "Collect level 2 Org headlines from DIRECTORY.

SOURCE identifies where the entries came from."

  (let ((files
         (directory-files-recursively
          directory
          "\\.org$"))

        (headings nil))

    (dolist (file files)

      (with-temp-buffer

        (insert-file-contents file)

        (org-mode)

        
        (let ((tree
               (org-element-parse-buffer)))

          (org-element-map
              tree
              'headline

            (lambda (headline)

              (when
                  (= (org-element-property
                      :level
                      headline)
                     2)

                (let* ((title
                        (org-element-property
                         :raw-value
                         headline))

                       (position
                        (org-element-property
                         :begin
                         headline))

                       (tags
                        (or
                         (org-element-property
                          :tags
                          headline)
                         '()))

                       (subtree
                        (buffer-substring-no-properties
                         position
                         (org-element-property
                          :end
                          headline)))


                       (timestamps nil))


                  ;; Collect timestamps inside subtree

                  (with-temp-buffer

                    (insert subtree)

                    (goto-char
                     (point-min))

                    (while
                        (re-search-forward
                         "\\[[0-9]+-[0-9]+-[^]]*\\]"
                         nil
                         t)

                      (push
                       (match-string 0)
                       timestamps)))


                  ;; Move point to headline for properties

                  (goto-char position)

                  (org-back-to-heading t)


                  (push

                   (make-my-org-browser-note

                    :title title

                    :file file

                    :position position


                    :timestamp
                    (if timestamps

                        (mapconcat
                         #'identity
                         (reverse timestamps)
                         ", ")

                      "—")


                    :tags tags

                    :category
                    (file-name-base file)


                    :source source


                    :promoted
                    (equal
                     (org-entry-get nil "PROMOTED")
                     "t")


                    :denote-file
                    (org-entry-get nil "DENOTE"))

                   headings))))))))


    (nreverse headings)))

;; --------------------------------------------------
;; Headline for generic collector
;; --------------------------------------------------

(defun my-org-browser--headline-timestamp ()
  "Return first timestamp in current subtree."

  (save-excursion

    (let ((end
           (save-excursion
             (org-end-of-subtree t t))))

      (goto-char (point))

      (if
          (re-search-forward
           "\\[[0-9]+-[0-9]+-[^]]+\\]"
           end
           t)

          (match-string-no-properties 0)

        "—"))))

;; --------------------------------------------------
;; Normalize tags
;; --------------------------------------------------


(defun my-org-browser--normalize-tags (tags)
  "Return Org tags as plain strings."

  (mapcar
   (lambda (tag)
     (if (stringp tag)
         (substring-no-properties tag)
       (format "%s" tag)))

   (or tags '())))

;; --------------------------------------------------
;; Normalize
;; --------------------------------------------------

(defun my-org-browser--stringify-org-value (value)
  "Convert Org element values to plain strings."

  (cond

   ((null value)
    nil)

   ;; Already a string
   ((stringp value)
    value)

   ;; Org element object:
   ;; represented as a list whose first element is a symbol
   ((and (listp value)
         (symbolp (car value)))
    (or
     (org-element-property :raw-value value)
     (org-element-property :value value)
     (format "%s" value)))

   ;; List of strings/elements
   ((listp value)
    (mapcar
     #'my-org-browser--stringify-org-value
     value))

   ;; Fallback
   (t
    (format "%s" value))))

;; --------------------------------------------------
;; Generic collector for rest of org files
;; --------------------------------------------------

(defun my-org-browser--collect-org-file (file category source)
  "Collect level 2 headlines from FILE."

  (when (file-exists-p file)

    (let (items)

      (with-temp-buffer

        (insert-file-contents file)

        (org-mode)

        (org-element-map
            (org-element-parse-buffer)
            'headline

          (lambda (headline)

            (when
                (= (org-element-property :level headline)
                   2)

              (let* ((raw-title
                      (org-element-property
                       :title
                       headline))

                     (title
                      (cond

                       ;; normal headline
                       ((stringp raw-title)
                        raw-title)


                       ;; headline title is a list of Org elements
                       ((listp raw-title)

                        (mapconcat
                         (lambda (element)

                           (cond

                            ;; plain text part
                            ((stringp element)
                             element)

                            ;; org-element objects are lists
                            ((and
                              (listp element)
                              (plist-member
                               (cadr element)
                               :raw-link))

                             (or
                              (plist-get
                               (cadr element)
                               :path)

                              ""))

                            ((and
                              (listp element)
                              (plist-member
                               (cadr element)
                               :raw-value))

                             (plist-get
                              (cadr element)
                              :raw-value))

                            (t
                             "")))

                         raw-title
                         ""))


                       (t
                        (format "%s" raw-title))))


                     (position
                      (org-element-property
                       :begin
                       headline))


                     (tags
                      (org-element-property
                       :tags
                       headline))


                     (timestamp
                      nil))


                ;; Find timestamp in subtree

                (save-excursion

                  (goto-char position)

                  (org-back-to-heading t)

                  (let ((end
                         (save-excursion
                           (org-end-of-subtree t t))))

                    (when
                        (re-search-forward
                         "\\[[0-9]+-[0-9]+-[^]]+\\]"
                         end
                         t)

                      (setq timestamp
                            (match-string 0)))))


                (push

                 (make-my-org-browser-note

                  :title title

                  :file file

                  :position position

                  :timestamp
                  (or timestamp "—")

                  :tags
                  (or tags '())

                  :category category

                  :source source)

                 items))))))


      (nreverse items))))

;; --------------------------------------------------
;; Source sleector
;; --------------------------------------------------


(defun my-org-browser-show-tasks ()
  "Show tasks."
  (interactive)
  (my-org-browser-switch-source 'tasks))


(defun my-org-browser-show-contacts ()
  "Show contacts."
  (interactive)
  (my-org-browser-switch-source 'contacts))


(defun my-org-browser-show-bookmarks ()
  "Show bookmarks."
  (interactive)
  (my-org-browser-switch-source 'bookmarks))


;; --------------------------------------------------
;; Collect contacts
;; --------------------------------------------------


(defun my-org-browser--collect-contacts ()
  "Collect contacts."

  (my-org-browser--collect-org-file
   "~/org/contacts.org"
   "contacts"
   'contacts))

;; --------------------------------------------------
;; Collect bookmarks
;; --------------------------------------------------


(defun my-org-browser--collect-bookmarks ()
  "Collect bookmarks."

  (my-org-browser--collect-org-file
   "~/org/bookmarks.org"
   "bookmarks"
   'bookmarks))

;; --------------------------------------------------
;; Collect notes
;; --------------------------------------------------

(defun my-org-browser--collect-notes ()
  "Collect notes."

  (my-org-browser--collect-org-headlines
   my-org-browser-directory
   'notes))

;; --------------------------------------------------
;; Collect tasks
;; --------------------------------------------------

(defun my-org-browser--collect-tasks ()
  "Collect tasks."

  (let ((items
         (my-org-browser--collect-org-file
          "~/org/tasks.org"
          "tasks"
          'tasks)))

    (cl-remove-if-not

     (lambda (note)

       (let ((file
              (my-org-browser-note-file note))

             (pos
              (my-org-browser-note-position note)))

         (with-temp-buffer

           (insert-file-contents file)

           (goto-char pos)

           (org-mode)

           (org-back-to-heading t)

           (member
            (org-get-todo-state)
            org-todo-keywords-1))))

     items)))

;; --------------------------------------------------
;; Collect Web
;; --------------------------------------------------

(defun my-org-browser--collect-web ()
  "Collect web files."

  (let ((files
         (directory-files-recursively
          my-org-browser-web-directory
          "\\.org$"))

        (web nil))


    (dolist (file files)

      (with-temp-buffer

        (insert-file-contents file)

        (org-mode)


        (let* ((title
                (or
                 (cadar
                  (org-collect-keywords
                   '("title")))

                 (file-name-base file)))


               (date
                (when
                    (org-collect-keywords
                     '("date"))

                  (cadar
                   (org-collect-keywords
                    '("date")))))


               (tags
                (my-org-browser--web-tags))


               (promoted
                (my-org-browser--web-promoted-p))


               (denote-file
                (when
                    (org-collect-keywords
                     '("denote"))

                  (cadar
                   (org-collect-keywords
                    '("denote"))))))



          (push

           (make-my-org-browser-note

            :title title

            :file file

            ;; web are whole files
            :position 1


            :timestamp
            (or date "—")


            :tags
            tags


            :category
            "web"


            :source
            'web


            :promoted
            promoted


            :denote-file
            denote-file)

           web))))



    (nreverse web)))

;; --------------------------------------------------
;; Refresh browser
;; --------------------------------------------------

(defun my-org-browser--refresh (&optional filter)
  "Refresh browser list.

FILTER is optional predicate."

  (setq my-org-browser--alist

        (funcall

         (alist-get
          my-org-browser-current-source
          my-org-browser-collectors)))


  ;; newest first

  (setq my-org-browser--alist

        (sort
         my-org-browser--alist

         (lambda (a b)

           (let ((ta
                  (my-org-browser--time-from-string
                   (my-org-browser-note-timestamp a)))

                 (tb
                  (my-org-browser--time-from-string
                   (my-org-browser-note-timestamp b))))

             (and ta tb
                  (time-less-p tb ta))))))


  (let ((entries nil))


    (dolist (note my-org-browser--alist)

      (when
          (or
           (not filter)
           (funcall filter note))


        (let* ((title
                (my-org-browser-note-title note))

               (file
                (my-org-browser-note-file note))

               (pos
                (my-org-browser-note-position note))

               (time
                (my-org-browser-note-timestamp note))

               (tags
                (my-org-browser-note-tags note))

               (category
                (my-org-browser-note-category note))

               (promoted
                (if (my-org-browser-note-promoted note)
                    "✓"
                  ""))

               (display-title
                (if
                    (member
                     (cons file pos)
                     my-org-browser--marked)

                    (concat "* " title)

                  title)))


          (push

           (list
            title


            (vector

             (propertize
              display-title
              'file file
              'pos pos
              'source
              (my-org-browser-note-source note)
              'face
              'my-org-browser-title-face)

             (propertize
              time
              'face
              'my-org-browser-time-face)

             (propertize
              category
              'face
              'my-org-browser-category-face)

             (propertize
              (string-join
               (or tags '())
               ", ")
              'face
              'my-org-browser-tags-face)

             (propertize
              promoted
              'face
              'my-org-browser-category-face)))

           entries))))



    (setq tabulated-list-entries
          (nreverse entries))


    (tabulated-list-init-header)

    (tabulated-list-revert)))



(defun my-org-browser-refresh ()
  "Refresh browser and update preview."

  (interactive)

  (my-org-browser--refresh)

  (my-org-browser--preview-current))


;; --------------------------------------------------
;; Preview pane
;; --------------------------------------------------

;; (defun my-org-browser--preview-current ()
;;   "Update preview buffer with current note."

;;   (when (eq major-mode 'my-org-browser-mode)

;;     (let ((entry (tabulated-list-get-entry)))

;;       (when entry

;;         (let* ((title
;;                 (aref entry 0))

;;                (file
;;                 (get-text-property
;;                  0
;;                  'file
;;                  title))

;;                (pos
;;                 (get-text-property
;;                  0
;;                  'pos
;;                  title))

;;                (source
;;                 (get-text-property
;;                  0
;;                  'source
;;                  title)))


;;           (when (and file pos)

;;             (with-current-buffer
;;                 (get-buffer-create
;;                  my-org-browser-preview-buffer)

;;               (let ((inhibit-read-only t))

;;                 ;; --------------------------------------------------
;;                 ;; Load file
;;                 ;; --------------------------------------------------

;;                 (erase-buffer)

;;                 (insert-file-contents file)

;;                 (org-mode)

;;                 ;; No line numbers in preview
;;                 (display-line-numbers-mode -1)

;;                 ;; Remove any previous narrowing
;;                 (widen)

;;                 ;; --------------------------------------------------
;;                 ;; Go to selected item
;;                 ;; --------------------------------------------------

;;                 (goto-char pos)

;;                 ;; Make sure point is on the headline
;;                 (org-back-to-heading t)

;;                 ;; Reveal the selected entry
;;                 (org-show-entry)

;;                 ;; --------------------------------------------------
;;                 ;; Narrow preview to selected subtree
;;                 ;; --------------------------------------------------

;;                 (condition-case nil

;;                     (org-narrow-to-subtree)

;;                   (error
;;                    (widen)))

;;                 ;; --------------------------------------------------
;;                 ;; Contacts
;;                 ;;
;;                 ;; Show everything inside the contact subtree,
;;                 ;; including the PROPERTIES drawer.
;;                 ;; --------------------------------------------------

;;                 (when (eq source 'contacts)

;;                   (org-show-all))

;;                 ;; --------------------------------------------------
;;                 ;; Position preview at beginning
;;                 ;; --------------------------------------------------

;;                 (goto-char (point-min))

;;                 ;; Preview is read-only
;;                 (read-only-mode 1)))))))))


(defun my-org-browser--preview-current ()
  "Update preview buffer with current note."

  (when (eq major-mode 'my-org-browser-mode)

    (let ((entry (tabulated-list-get-entry)))

      (when entry

        (let* ((title
                (aref entry 0))

               (file
                (get-text-property
                 0
                 'file
                 title))

               (pos
                (get-text-property
                 0
                 'pos
                 title))

               (source
                (get-text-property
                 0
                 'source
                 title)))

          (when (and file
                     (file-exists-p file))

            (with-current-buffer
                (get-buffer-create
                 my-org-browser-preview-buffer)

              (let ((inhibit-read-only t))

                ;; Start clean every time.
                (erase-buffer)

                ;; Load selected file.
                (insert-file-contents file)

                (org-mode)

                ;; No line numbers in preview.
                (display-line-numbers-mode -1)

                ;; Always start from a fully widened buffer.
                (widen)

                ;; --------------------------------------------------
                ;; Web
                ;;
                ;; A web item represents the entire file, so do NOT
                ;; call org-back-to-heading or narrow-to-subtree.
                ;; --------------------------------------------------

                (if (eq source 'web)

                    (goto-char (point-min))

                  ;; ------------------------------------------------
                  ;; Normal Org subtree sources
                  ;; ------------------------------------------------

                  (when pos
                    (goto-char
                     (min pos (point-max)))

                    ;; Position should point to a headline.
                    ;; Keep this protected so a malformed/stale
                    ;; position cannot kill the preview hook.
                    (condition-case nil

                        (progn
                          (org-back-to-heading t)
                          (org-show-entry)
                          (org-narrow-to-subtree))

                      (error
                       ;; If the position is invalid, just show
                       ;; the complete file rather than breaking
                       ;; the preview system.
                       (widen)
                       (goto-char (point-min))))))

                ;; Contacts need their full subtree, including
                ;; the PROPERTIES drawer.
                (when (and (eq source 'contacts)
                           (buffer-narrowed-p))

                  (org-show-all))

                ;; Always display from the beginning.
                (goto-char (point-min))

                ;; Preview is read-only.
                (read-only-mode 1)))))))))


;; --------------------------------------------------
;; Return note at point
;; --------------------------------------------------

(defun my-org-browser-current-note ()
  "Return the note at point."

  (let ((entry
         (tabulated-list-get-entry)))

    (when entry

      (let* ((title
              (aref entry 0))

             (file
              (get-text-property
               0
               'file
               title))

             (pos
              (get-text-property
               0
               'pos
               title)))

        (cl-find-if

         (lambda (note)

           (and
            (equal
             (my-org-browser-note-file note)
             file)

            (equal
             (my-org-browser-note-position note)
             pos)))

         my-org-browser--alist)))))


;; --------------------------------------------------
;; Note Content
;; --------------------------------------------------


(defun my-org-browser--note-subtree-content (note)
  "Return Org subtree content for NOTE."

  (with-temp-buffer

    (insert-file-contents
     (my-org-browser-note-file note))

    (goto-char
     (my-org-browser-note-position note))

    (org-mode)

    (org-back-to-heading t)

    (let ((begin
           (point))

          (end
           (save-excursion
             (org-end-of-subtree t t))))

      (buffer-substring-no-properties
       begin
       end))))


;; --------------------------------------------------
;;  Clean Up Tags for denote
;; --------------------------------------------------


(defun my-org-browser--denote-tags (note)
  "Return NOTE tags formatted for Denote."

  (let ((tags
         (my-org-browser-note-tags note)))

    (when tags

      (mapcar
       (lambda (tag)

         (replace-regexp-in-string
          ":"
          ""
          tag))

       tags))))


;; --------------------------------------------------
;;  Clean Up body for denote
;; --------------------------------------------------

(defun my-org-browser--promote-body (note)
  "Return cleaned body text from NOTE for Denote promotion."

  (let ((content
         (my-org-browser--note-subtree-content note)))

    (with-temp-buffer

      (insert content)

      (org-mode)

      ;; Remove headline line only

      (goto-char (point-min))

      (when (org-at-heading-p)

        (delete-region
         (line-beginning-position)
         (line-beginning-position 2)))


      ;; Remove property drawer

      (goto-char (point-min))

      (when
          (re-search-forward
           "^:PROPERTIES:[ \t]*$"
           nil
           t)

        (let ((begin
               (line-beginning-position)))

          (when
              (re-search-forward
               "^:END:[ \t]*$"
               nil
               t)

            (delete-region
             begin
             (line-beginning-position 2)))))


      ;; Remove standalone timestamps

      (goto-char (point-min))

      (while
          (re-search-forward
           "^\\[[0-9]+-[0-9]+-[^]]+\\][ \t]*$"
           nil
           t)

        (replace-match ""))


      (string-trim
       (buffer-string)))))



;; --------------------------------------------------
;;  Note promote marker
;; --------------------------------------------------



(defun my-org-browser--mark-note-promoted (note denote-file)
  "Mark NOTE subtree as promoted."

  (with-current-buffer
      (find-file-noselect
       (my-org-browser-note-file note))

    (goto-char
     (my-org-browser-note-position note))

    (org-back-to-heading t)

    (org-set-property
     "PROMOTED"
     "t")

    (org-set-property
     "DENOTE"
     denote-file)

    (save-buffer)))


;; --------------------------------------------------
;;  Web promote marker
;; --------------------------------------------------


(defun my-org-browser--mark-web-promoted (source denote-file)
  "Mark web file as promoted."

  (with-current-buffer
      (find-file-noselect source)

    (goto-char (point-min))

    (unless
        (re-search-forward
         "^#\\+promoted:"
         nil
         t)

      (insert
       "#+promoted: t\n"
       "#+denote: "
       denote-file
       "\n\n"))

    (save-buffer)))

;; --------------------------------------------------
;;  Clean Up web for denote
;; --------------------------------------------------

(defun my-org-browser--web-tags ()
  "Extract tags from an web "

  (let ((tags nil))


    ;; File tags:
    ;; #+filetags: :emacs:org:

    (let ((filetags
           (org-collect-keywords '("filetags"))))

      (when filetags

        (setq tags
              (split-string
               (cadar filetags)
               ":"
               t))))


    ;; Headline tags:
    ;; * Title :emacs:org:

    (when (not tags)

      (goto-char (point-min))

      (when (re-search-forward
             "^\\*+ .*\\(:[^ \n]+:\\)"
             nil
             t)

        (goto-char
         (match-beginning 0))

        (setq tags
              (org-get-tags))))


    (delete-dups tags)))

;; --------------------------------------------------
;;  Clean Up web for denote
;; --------------------------------------------------

(defun my-org-browser--web-content (note)
  "Return web body without Org metadata."

  (with-temp-buffer

    (insert-file-contents
     (my-org-browser-note-file note))

    (org-mode)


    ;; Remove title headline

    (goto-char (point-min))

    (when
        (re-search-forward
         "^\\*+ .*"
         nil
         t)

      (delete-region
       (line-beginning-position)
       (line-beginning-position 2)))


    ;; Remove property drawer

    (goto-char (point-min))

    (when
        (re-search-forward
         "^:PROPERTIES:$"
         nil
         t)

      (let ((begin
             (line-beginning-position)))

        (when
            (re-search-forward
             "^:END:$"
             nil
             t)

          (delete-region
           begin
           (line-beginning-position 2)))))


    ;; Remove standalone timestamps

    (goto-char (point-min))

    (while
        (re-search-forward
         "^\\[[0-9]+-[0-9]+-[^]]+\\][ \t]*$"
         nil
         t)

      (replace-match ""))


    (string-trim
     (buffer-string))))


;; --------------------------------------------------
;; Read note promoted
;; --------------------------------------------------


(defun my-org-browser--note-promoted-p ()
  "Return non-nil if current subtree is promoted."

  (equal
   (org-entry-get nil "PROMOTED")
   "t"))


;; --------------------------------------------------
;; Read web promoted
;; --------------------------------------------------

(defun my-org-browser--web-promoted-p ()
  "Return non-nil if current web is promoted."

  (goto-char (point-min))

  (re-search-forward
   "^#\\+promoted:[ \t]*t"
   nil
   t))

;; --------------------------------------------------
;; Open selected item
;; --------------------------------------------------

(defun my-org-browser-open ()
  "Open selected browser item.

Bookmarks open their headline URL.
Web items open their original source URL.
Notes, tasks, and contacts open their Org location."
  (interactive)

  (let ((note (my-org-browser-current-note)))

    (when note

      (let ((file
             (my-org-browser-note-file note))

            (pos
             (my-org-browser-note-position note))

            (source
             (my-org-browser-note-source note)))

        (pcase source

          ;; --------------------------------------------------
          ;; Bookmarks
          ;; --------------------------------------------------

          ('bookmarks

           (with-temp-buffer

             (insert-file-contents file)

             (org-mode)

             (goto-char pos)

             (org-back-to-heading t)

             (let ((url
                    (org-entry-get nil "URL" t)))

               ;; Your bookmarks don't use a URL property.
               ;; Extract the first Org link from the headline.
               (unless url

                 (when
                     (re-search-forward
                      org-bracket-link-regexp
                      (line-end-position)
                      t)

                   (setq url
                         (match-string-no-properties 1))))


               (if (and url
                        (string-match-p
                         "\\`https?://"
                         url))

                   (progn
                     (browse-url-xdg-open url)
                     (message "Opening: %s" url))

                 (user-error
                  "Bookmark has no valid URL")))))


          ;; --------------------------------------------------
          ;; Web pages
          ;; --------------------------------------------------

          ('web

           (with-temp-buffer

             (insert-file-contents file)

             (org-mode)

             (goto-char (point-min))

             (let (url)

               ;; Web captures use:
               ;;
               ;; #+source: [https://example.com](https://example.com)
               ;;
               (when
                   (re-search-forward
                    "^#\\+source:[ \t]+\\(.*\\)$"
                    nil
                    t)

                 (let ((source-line
                        (match-string-no-properties 1)))

                   ;; Markdown link:
                   ;; [https://example.com](https://example.com)
                   (when
                       (string-match
                        "\\[\\(https?://[^]]+\\)\\]"
                        source-line)

                     (setq url
                           (match-string 1 source-line)))

                   ;; Fallback: plain URL
                   (unless url

                     (when
                         (string-match
                          "\\(https?://[^][() \t\n]+\\)"
                          source-line)

                       (setq url
                             (match-string 1 source-line))))))


               (if (and url
                        (string-match-p
                         "\\`https?://"
                         url))

                   (progn
                     (browse-url-xdg-open url)
                     (message "Opening: %s" url))

                 (user-error
                  "Web entry has no valid #+source URL")))))


          ;; --------------------------------------------------
          ;; Notes / Tasks / Contacts
          ;; --------------------------------------------------

          (_

           (my-org-browser--quit-browser)

           (find-file file)

           (goto-char pos)

           (when (derived-mode-p 'org-mode)

             (org-back-to-heading t)

             (org-reveal))))))))


;; --------------------------------------------------
;; Edit note
;; --------------------------------------------------

(defun my-org-browser-edit-current ()
  "Edit current browser item in a new window."

  (interactive)

  (let ((note
         (my-org-browser-current-note)))

    (when note

      (let ((file
             (my-org-browser-note-file note))

            (pos
             (my-org-browser-note-position note)))

        (let ((preview-window
               (get-buffer-window
                my-org-browser-preview-buffer)))

          (when preview-window

            (select-window preview-window)

            (split-window-below)

            (other-window 1)

            (find-file file)

            (goto-char pos)

            (org-reveal)))))))

;; --------------------------------------------------
;; Promote to denote
;; --------------------------------------------------

(defun my-org-browser-promote-current ()
  "Promote current browser item to Knowledge."

  (interactive)

  (let ((note
         (my-org-browser-current-note)))

    (when note

      (pcase (my-org-browser-note-source note)

        ('notes

         (require 'denote)

         (let* ((title
                 (my-org-browser-note-title note))

                (body
                 (my-org-browser--promote-body note))

                (tags
                 (my-org-browser--denote-tags note))

                (file
                 (denote
                  title
                  tags
                  nil)))

           (with-current-buffer
               (find-file-noselect file)

             (goto-char (point-max))

             (insert
              body)

             (save-buffer))

           (my-org-browser--mark-note-promoted
            note
            file)

           (message
            "Created Denote note: %s"
            title)))

        ('web

         (require 'denote)

         (let* ((title
                 (my-org-browser-note-title note))

                (body
                 (my-org-browser--web-content note))

                (tags
                 (cons
                  "web"
                  (my-org-browser--denote-tags note)))

                (source
                 (my-org-browser-note-file note))

                (denote-directory
                 my-org-browser-knowledge-web-directory)

                (file
                 (denote
                  title
                  tags
                  nil)))


           (with-current-buffer
               (find-file-noselect file)

             (goto-char (point-max))

             (insert
              "\n\n#+source: "
              source
              "\n\n"
              body)

             (save-buffer))

           (my-org-browser--mark-web-promoted
            source
            file)

           (message
            "Created web: %s"
            title)))))))

;; --------------------------------------------------
;; Add note/web etc depending on source
;; --------------------------------------------------

(defun my-org-browser-add ()
  "Create new item matching current browser source."

  (interactive)

  (let ((refresh
         (lambda ()

           (when (get-buffer "*Org Browser*")

             (with-current-buffer "*Org Browser*"

               (my-org-browser-refresh))))))


    (add-hook
     'org-capture-after-finalize-hook
     refresh
     nil
     t)


    (pcase my-org-browser-current-source

      ;; Notes capture
      ('notes
       (org-capture nil "n"))


      ;; Tasks capture
      ('tasks
       (org-capture nil "t"))


      ;; Contacts capture
      ('contacts
       (org-capture nil "c"))


      ;; Bookmarks capture
      ('bookmarks
       (org-capture nil "b"))


      ;; web
      ('web
         (my/save-url-as-org-web))

      (_
       (message
        "No capture configured for %s"
        my-org-browser-current-source)))))

;; --------------------------------------------------
;; Delete current
;; --------------------------------------------------

(defun my-org-browser-delete-current ()
  "Delete current note, task, contact, bookmark, or web."

  (interactive)

  (let ((note
         (my-org-browser-current-note)))

    (when note

      (let* ((file
              (my-org-browser-note-file note))

             (pos
              (my-org-browser-note-position note))

             (title
              (my-org-browser-note-title note))

             (source
              (my-org-browser-note-source note)))


        (when
            (yes-or-no-p
             (format
              "Delete '%s'? "
              title))


          (pcase source


            ;; Org subtree sources
            ((or 'notes
                 'tasks
                 'contacts
                 'bookmarks)

             (with-current-buffer
                 (find-file-noselect file)

               (save-excursion

                 (goto-char pos)

                 (org-back-to-heading t)

                 (org-cut-subtree))

               (save-buffer)))


            ;; Whole web files
            ('web

             (when
                 (file-exists-p file)

               (delete-file file))))


          ;; Remove mark if it existed

          (setq my-org-browser--marked

                (remove
                 (cons file pos)
                 my-org-browser--marked))


          ;; Rebuild list

          (my-org-browser-refresh)


          ;; Update preview safely

          (when
              (eq major-mode 'my-org-browser-mode)

            (condition-case nil

                (my-org-browser--preview-current)

              (error
               (message
                "Preview cleared")))))))))



;; --------------------------------------------------
;; Delete current
;; --------------------------------------------------



(defun my-org-browser-delete-marked ()
  "Delete all marked notes, tasks, contacts, bookmarks, or web files."
  (interactive)

  (if (null my-org-browser--marked)
      (message "No notes marked")

    (let ((marked my-org-browser--marked))

      (when
          (yes-or-no-p
           (format "Delete %d marked item%s? "
                   (length marked)
                   (if (= (length marked) 1) "" "s")))

        ;; Group marked items by file.
        ;;
        ;; We use the stored position only for sorting.  Items in the
        ;; same file must be deleted from bottom to top because deleting
        ;; an Org subtree changes the positions of everything below it.
        (let ((by-file nil))

          (dolist (item marked)

            (let* ((file (car item))
                   (pos  (cdr item))
                   (group (assoc file by-file)))

              (if group

                  (push pos (cdr group))

                (push (cons file (list pos))
                      by-file))))


          ;; Process every file.
          (dolist (group by-file)

            (let* ((file (car group))
                   (positions (cdr group)))

              ;; Web entries represent whole files.
              (if (eq my-org-browser-current-source 'web)

                  (when (file-exists-p file)
                    (delete-file file))

                ;; Org headline entries.
                (when (file-exists-p file)

                  (with-current-buffer
                      (find-file-noselect file)

                    ;; Delete from the bottom upwards.
                    (dolist (pos
                             (sort (copy-sequence positions) #'>))

                      ;; Position may be slightly stale, so make sure
                      ;; it is still inside the buffer.
                      (when (<= pos (point-max))

                        (goto-char pos)

                        (condition-case err

                            (progn
                              (org-back-to-heading t)
                              (org-cut-subtree))

                          (error
                           (message
                            "Could not delete item at %s:%s: %s"
                            file
                            pos
                            (error-message-string err))))))

                    (save-buffer))))))


        ;; All marked entries have now been processed.
        (setq my-org-browser--marked nil)

        ;; Rebuild browser.
        (my-org-browser-refresh)

        (message "Marked items deleted"))))))


;; --------------------------------------------------
;; yet another helper
;; --------------------------------------------------


(defun my-org-browser--headline-display-title (headline)
  "Return display title."

  (let ((title
         (org-element-property :title headline)))

    (if (and
         (listp title)
         (eq
          (org-element-type (car title))
          'link))

        (let ((link (car title)))

          (org-element-interpret-data
           (org-element-property
            :contents
            link)))

      (org-element-interpret-data title))))


;; --------------------------------------------------
;; Marking
;; --------------------------------------------------

(defun my-org-browser-toggle-mark ()
  "Toggle mark."

  (interactive)

  (let ((note
         (my-org-browser-current-note)))

    (when note

      (let ((item
             (cons
              (my-org-browser-note-file note)

              (my-org-browser-note-position note))))

        (if
            (member item my-org-browser--marked)

            (setq my-org-browser--marked
                  (remove item
                          my-org-browser--marked))

          (push item
                my-org-browser--marked)))))


  (my-org-browser-refresh))


;; --------------------------------------------------
;; Reset filters
;; --------------------------------------------------

;; (defun my-org-browser-reset-filters ()
;;   "Reset browser."
;;
;;   (interactive)
;;
;;   (my-org-browser--refresh)
;;
;;   (my-org-browser--preview-current))


(defun my-org-browser-reset-filters ()
  "Reset browser."

  (interactive)

  (my-org-browser-refresh))



;; --------------------------------------------------
;; Filter Content
;; --------------------------------------------------



(defun my-org-browser-filter ()
  "Filter notes and web by title and tags.

Examples:
  Curly
  :www:
  Curly :www:
"

  (interactive)

  (let* ((input
          (read-string "Filter: "))

         (words
          (split-string input " " t))

         (text "")

         (tags nil))


    ;; parse input

    (dolist (word words)

      (if (string-prefix-p ":" word)

          (push
           (replace-regexp-in-string
            ":"
            ""
            word)

           tags)

        (setq text
              (concat text " " word))))


    (setq text
          (string-trim text))


    (my-org-browser--refresh

     (lambda (note)

       (let ((title
              (my-org-browser-note-title note))

             (note-tags
              (mapcar
               (lambda (tag)

                 (replace-regexp-in-string
                  ":"
                  ""
                  tag))

               (my-org-browser-note-tags note))))


         (and

          (or
           (string-empty-p text)

           (string-match-p
            (regexp-quote text)
            title))


          (or
           (null tags)

           (cl-every
            (lambda (tag)

              (member
               tag
               note-tags))

            tags))))))


    (my-org-browser--preview-current)))

;; --------------------------------------------------
;; Source switching
;; --------------------------------------------------

(defun my-org-browser-switch-source (source)
  "Switch browser SOURCE."

  (interactive)

  (setq my-org-browser-current-source source)

  ;; (my-org-browser--refresh)
  ;;
  ;; (my-org-browser--preview-current)
  (my-org-browser-refresh))


(defun my-org-browser-show-notes ()
  "Show notes."

  (interactive)

  (my-org-browser-switch-source 'notes))


(defun my-org-browser-show-web ()
  "Show web."

  (interactive)

  (my-org-browser-switch-source 'web))


;; --------------------------------------------------
;; Quit browser
;; --------------------------------------------------

(defun my-org-browser--quit-browser ()
  "Close Org browser and kill buffers visiting files under ~/org/."

  (interactive)

  (remove-hook
   'post-command-hook
   #'my-org-browser--preview-current
   t)

  ;; Kill Org buffers visiting files under ~/org/
  (let ((org-directory
         (file-truename "~/org/")))

    (dolist (buffer (buffer-list))

      (with-current-buffer buffer

        (let ((file buffer-file-name))

          (when
              (and file
                   (file-in-directory-p
                    (file-truename file)
                    org-directory))

            (kill-buffer buffer))))))

  ;; Kill browser buffer
  (when
      (get-buffer "*Org Browser*")

    (kill-buffer "*Org Browser*"))

  ;; Kill preview buffer
  (when
      (get-buffer my-org-browser-preview-buffer)

    (kill-buffer
     my-org-browser-preview-buffer))

  ;; Restore normal window layout
  (delete-other-windows))

;; --------------------------------------------------
;; Major mode
;; --------------------------------------------------

(define-derived-mode my-org-browser-mode
  tabulated-list-mode
  "OrgBrowser"

  "Browse Org notes."

  (setq tabulated-list-format

        [("Title" 45 t)
         ("Timestamp" 25 t)
         ("Category" 15 t)
         ("Tags" 25 t)
         ("Denote" 3 nil)])

  (setq tabulated-list-padding 2)

  (tabulated-list-init-header)


  (setq tabulated-list-sort-key nil)



  ;; Keybindings

  (define-key
   my-org-browser-mode-map
   (kbd "RET")
   #'my-org-browser-open)


  (define-key
   my-org-browser-mode-map
   (kbd "q")
   #'my-org-browser--quit-browser)


  (define-key
   my-org-browser-mode-map
   (kbd "s")
   #'my-org-browser-filter)


  (define-key
   my-org-browser-mode-map
   (kbd "/")
   #'my-org-browser-filter)


  (define-key
   my-org-browser-mode-map
   (kbd "C-/")
   #'my-org-browser-reset-filters)


  (define-key
   my-org-browser-mode-map
   (kbd "w")
   #'my-org-browser-show-web)


  (define-key
   my-org-browser-mode-map
   (kbd "n")
   #'my-org-browser-show-notes)

  (define-key
   my-org-browser-mode-map
   (kbd "p")
   #'my-org-browser-promote-current)

  (define-key
   my-org-browser-mode-map
   (kbd "a")
   #'my-org-browser-add)


  (define-key
   my-org-browser-mode-map
   (kbd "m")
   #'my-org-browser-toggle-mark)


  (define-key
   my-org-browser-mode-map
   (kbd "x")
   #'my-org-browser-delete-marked)


  (define-key
   my-org-browser-mode-map
   (kbd "d")
   #'my-org-browser-delete-current)

  (define-key
   my-org-browser-mode-map
   (kbd "e")
   #'my-org-browser-edit-current)

  (define-key
   my-org-browser-mode-map
   (kbd "t")
   #'my-org-browser-show-tasks)


  (define-key
   my-org-browser-mode-map
   (kbd "c")
   #'my-org-browser-show-contacts)


  (define-key
   my-org-browser-mode-map
   (kbd "b")
   #'my-org-browser-show-bookmarks)


  ;; live preview

  (add-hook
   'post-command-hook
   #'my-org-browser--preview-current
   nil
   t))



;; --------------------------------------------------
;; Open browser
;; --------------------------------------------------

;;;###autoload
(defun my-org-browser-show ()
  "Open Org notes browser."

  (interactive)


  (delete-other-windows)



  (let ((buffer
         (get-buffer-create
          "*Org Browser*")))


    (switch-to-buffer buffer)

    (my-org-browser-mode)

    (my-org-browser--refresh))



  ;; preview window

  (let ((window
         (split-window-right)))

    (select-window window)


    (switch-to-buffer

     (get-buffer-create
      my-org-browser-preview-buffer))


    (erase-buffer)

    (org-mode)

    ;; Preview is intentionally line-number-free.
    (display-line-numbers-mode -1)

    (read-only-mode 1))



  ;; return to list

  (other-window -1)


  (my-org-browser--preview-current))




(provide 'org-browser)

;;; my-org-browser.el ends here
