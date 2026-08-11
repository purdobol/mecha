;;; omni-org-sources.el --- declares custom org sources -*- lexical-binding: t -*-

(after! consult-omni
  (require 'consult-omni-sources)
  (require 'org)

  ;; --------------------------------------------------
  ;; Org Bookmarks
  ;; --------------------------------------------------
  (defun my-consult-omni-org-bookmarks ()
    "Parse ~/org/bookmarks.org into a list of plists with :title and :url."
    (let ((file (expand-file-name "~/org/bookmarks.org"))
          results)
      (when (file-exists-p file)
        (with-temp-buffer
          (insert-file-contents file)
          (org-mode)
          (org-element-map (org-element-parse-buffer) 'link
            (lambda (link)
              (let* ((type (org-element-property :type link))
                     (raw-url (string-trim (org-element-property :path link)))
                     (url (cond
                           ((and raw-url (string-match-p "^https?://" raw-url)) raw-url)
                           ((and raw-url (string-prefix-p "//" raw-url)) (concat "https:" raw-url))
                           ((and raw-url (not (string-empty-p raw-url))) (concat "https://" raw-url))
                           (t nil)))
                     (title (or (when (org-element-property :contents-begin link)
                                  (string-trim
                                   (buffer-substring-no-properties
                                    (org-element-property :contents-begin link)
                                    (org-element-property :contents-end link))))
                                url)))
                (when (and url (member type '("http" "https")))
                  (push (list :title title :url url) results))))))
        (nreverse results))))

  (defun my-consult-omni-org-bookmarks-builder (&optional input &key callback &allow-other-keys)
    "Builder function for Org Bookmarks candidates."
    (let* ((all (my-consult-omni-org-bookmarks))
           (filtered (if (and input (> (length input) 0))
                         (seq-filter
                          (lambda (o)
                            (string-match-p (regexp-quote input)
                                            (plist-get o :title)))
                          all)
                       all))
           (candidates
            (mapcar (lambda (o)
                      (propertize (string-trim (plist-get o :title))
                                  'bookmark o
                                  'consult-omni-group "Bookmarks"
                                  'face font-lock-constant-face)) ;; Bookmarks color
                    filtered)))
      (when callback (funcall callback candidates))
      candidates))

  (defun my-consult-omni-org-bookmarks-action (candidate)
    "Open a bookmark candidate in a browser."
    (let ((plist (get-text-property 0 'bookmark candidate)))
      (when plist
        (browse-url (plist-get plist :url)))))

(defun my-consult-omni-org-bookmarks-annotate (candidate)
"Annotate a bookmark candidate with its URL."

(let* ((plist
        (get-text-property
         0
         'bookmark
         candidate))

       (url
        (plist-get plist :url)))

  (concat
   " "

   (propertize
    url
    'face
    'shadow))))


  (consult-omni-define-source
   "OrgBookmarks"
   :narrow-char ?b
   :type 'sync
   :request #'my-consult-omni-org-bookmarks-builder
   :on-callback #'my-consult-omni-org-bookmarks-action
   :group "Org Bookmarks"
   :annotate #'my-consult-omni-org-bookmarks-annotate
   :sort t
   :require-match nil)

  (setq consult-omni-multi-sources
        (append (cl-remove "OrgBookmarks" consult-omni-multi-sources :test #'string=)
                '("OrgBookmarks")))

  ;; --------------------------------------------------
  ;; Org Headings
  ;; --------------------------------------------------
  (defun my/notes-launcher (elisp-code)
    "Launch an Emacs command in the notes workspace via emacs-launcher."
    (start-process
     "emacs-notes-launcher"
     nil
     my/emacs-launcher-path
     elisp-code))

  ;; --------------------------------------------------
  ;; Headings parsing (Notes + Web)
  ;; --------------------------------------------------
  (defun my-consult-omni-org-headings ()
    "Return all org headings in ~/org/notes and ~/org/web.
Notes: all headlines.
Web: only #+title: or first-level heading."
    (let ((dirs '("~/org/notes" "~/org/web")))
      (cl-loop for dir in dirs
               append
               (cl-loop for file in (directory-files-recursively dir "\\.org$")
                        append
                        (with-temp-buffer
                          (insert-file-contents file)
                          (org-mode)
                          (if (string-match-p "/web/" file)
                              ;; Web: return a single-item list, wrap in list for append
                              (let (title pos)
                                (goto-char (point-min))
                                (when (re-search-forward "^#\\+title: \\(.*\\)$" nil t)
                                  (setq title (match-string 1)
                                        pos (match-beginning 0)))
                                (unless title
                                  (goto-char (point-min))
                                  (when (re-search-forward "^\\* \\(.*\\)$" nil t)
                                    (setq title (match-string 1)
                                          pos (match-beginning 0))))
                                (when title
                                  (list (list :title title :file file :pos (or pos 0))))) ;; wrap in list
                            ;; Notes: all headlines
                            (org-element-map (org-element-parse-buffer) 'headline
                              (lambda (hl)
                                (let ((title (org-element-property :raw-value hl))
                                      (pos (org-element-property :begin hl)))
                                  (when (and title pos)
                                    (list :title title :file file :pos pos)))))))))))

  (defun my-consult-omni-org-headings-builder (&optional input &key callback &allow-other-keys)
    "Builder function for Org Headings candidates with colors."
    (let* ((all (my-consult-omni-org-headings))
           (filtered (if (and input (> (length input) 0))
                         (seq-filter
                          (lambda (o)
                            (string-match-p (regexp-quote input)
                                            (plist-get o :title)))
                          all)
                       all))
           (candidates
            (mapcar (lambda (o)
                      (propertize (plist-get o :title)
                                  'org-heading o
                                  'consult-omni-group
                                  (cond
                                   ((string-match-p "/web/" (plist-get o :file))
                                    "Web")
                                   ((string-match-p "/notes/" (plist-get o :file))
                                    "Notes")
                                   (t "Other"))
                                  'face
                                  (cond
                                   ((string-match-p "/web/" (plist-get o :file))
                                    'font-lock-string-face)   ;; Web
                                   ((string-match-p "/notes/" (plist-get o :file))
                                    'font-lock-variable-name-face)  ;; Notes (more visible)
                                   (t 'default))))
                    filtered)))
      (when callback (funcall callback candidates))
      candidates))

  (defun my-consult-omni-org-headings-action (candidate)
    "Open an Org heading CANDIDATE in the 'consult' workspace via emacs-launcher."
    (let* ((plist (get-text-property 0 'org-heading candidate))
           (file (plist-get plist :file))
           (pos  (plist-get plist :pos)))
      (when (and (stringp file) (numberp pos))
        (let* ((escaped-file (my/escape-elisp-string (expand-file-name file)))
               (cmd (my/consult-elisp-command
                     (format "(find-file \"%s\") (goto-char %d) (recenter)"
                             escaped-file
                             pos))))
          (run-at-time 0 nil #'start-process "emacs-launcher" nil my/emacs-launcher-path cmd)))))

  (defun my-consult-omni-org-headings-annotate (candidate)
"Annotate an Org heading CANDIDATE with its file path."

(let* ((plist
        (get-text-property
         0
         'org-heading
         candidate))

       (file
        (plist-get plist :file)))

  (concat

   " "

   (propertize
    (file-name-nondirectory file)

    'face
    'shadow))))

  (consult-omni-define-source
   "OrgHeadings"
   :narrow-char ?h
   :type 'sync
   :request #'my-consult-omni-org-headings-builder
   :on-callback #'my-consult-omni-org-headings-action
   :group "Org Notes / Org Web"
   :annotate #'my-consult-omni-org-headings-annotate
   :sort t
   :require-match nil)

  (setq consult-omni-local-sources
        (append (cl-remove "OrgHeadings" consult-omni-local-sources :test #'string=)
                '("OrgHeadings"))))

(provide 'omni-org-sources)
