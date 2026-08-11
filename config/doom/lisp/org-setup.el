;;; ------------------------------
;;; Org Directory & Notes Setup
;;; ------------------------------

(require 'cl-lib)
(require 'org-capture)
(require 'elfeed-setup)


(setq org-directory "~/org")

(defvar my/org-notes-dir (expand-file-name "~/org/notes/"))
(defvar my/org-web-dir (expand-file-name "~/org/web/"))

;;; Ensure directories exist ONCE at startup
(defun my/ensure-org-directories ()
  "Ensure notes and web directories exist."
  (dolist (dir (list my/org-notes-dir my/org-web-dir))
    (unless (file-exists-p dir)
      (make-directory dir t))))
(my/ensure-org-directories)  ;; <--- no hook, run once

;;; ------------------------------
;;; Org Refile Targets
;;; ------------------------------
(setq org-refile-targets
      '(("~/org/tasks.org"     :maxlevel . 2)
        ("~/org/bookmarks.org" :maxlevel . 2)
        ("~/org/contacts.org"  :maxlevel . 2)
        ;; ("~/org/finances.org"  :maxlevel . 2)  <-- removed for speed
        ("~/org/ideas.org"     :maxlevel . 2)
        ("~/org/misc.org"      :maxlevel . 2)))

;;; ------------------------------
;;; Notes-per-Category System
;;; ------------------------------


(defun my/org-note-categories ()
  "Return current note categories."
  (mapcar #'file-name-base
          (directory-files my/org-notes-dir t "\\.org$")))

(defun my/org-ensure-file-heading (file)
  "Ensure FILE exists and has a top-level heading 'Notes'."
  (unless (file-exists-p file)
    (with-temp-file file
      (insert "#+title: " (file-name-base file) "\n\n* Notes\n"))))


(defun my/org-read-note-category ()
  "Prompt for note category and create file if missing."
  (let* ((existing (my/org-note-categories))
         (cat (completing-read
               "Category: "
               existing
               nil
               nil))
         (file (expand-file-name
                (concat cat ".org")
                my/org-notes-dir)))
    (unless (file-exists-p file)
      (with-temp-file file
        (insert "#+title: " cat "\n\n")
        (insert "* Notes\n")))
    file))

;;; ------------------------------
;;; Org Capture Templates
;;; ------------------------------


(defun my/setup-org-capture-templates ()
  "Define org-capture templates matching LightEmacs setup."
  (setq org-capture-templates nil)


  ;; Tasks
  (add-to-list 'org-capture-templates
               '("t" "Task" entry
                 (file+headline "~/org/tasks.org"
                                "Tasks & Projects")
                 "* TODO %^{Title} %^G\n%U\n:PROPERTIES:\n:CATEGORY: Task\n:END:\n%i"
                 :empty-lines 1))

  ;; Notes
  (add-to-list 'org-capture-templates
               `("n" "Note" entry
                 (file+headline
                  (lambda ()
                    (my/org-read-note-category))
                  "Notes")
                "* %^{Title} %^G\n%U\n:PROPERTIES:\n:CATEGORY: Note\n:END:\n%i"
                 :empty-lines 1))

  ;; Finance
  (add-to-list 'org-capture-templates
               '("f" "Finance Entry" entry
                 (file+headline "~/org/finances.org"
                                "Transactions")
                 "* %^{Title}\n%U\n:PROPERTIES:\n:CATEGORY: Finance\n:END:\n%i"
                 :empty-lines 1))

  ;; Bookmarks
  (add-to-list 'org-capture-templates
               '("b" "Bookmark" entry
                 (file+headline "~/org/bookmarks.org"
                                "Bookmarks & Links")
                 (function my/org-bookmark-template)
                 :empty-lines 1))

  ;; Contacts
  (add-to-list 'org-capture-templates
               '("c" "Contact" entry
                 (file+headline "~/org/contacts.org"
                                "Contacts & Networking")
                 "* %^{Name} :contact:\n:PROPERTIES:\n:EMAIL: %^{Email}\n:PHONE: %^{Phone}\n:BIRTHDAY: %^{Birthday}\n:ADDRESS: %^{Address}\n:CITY: %^{City}\n:COMPANY: %^{Company}\n:RELATIONSHIP: %^{Relationship}\n:END:\n%U\n\n%i"
                 :empty-lines 1))

;; Elfeed
(add-to-list 'org-capture-templates
  '("e" "Elfeed Feed" entry
    (file+headline "~/org/elfeed.org" "Feeds")
    "%(my/elfeed-capture-feed)"
    :empty-lines 1)))

(my/setup-org-capture-templates)

;;; ------------------------------
;;; Bookmark Helpers
;;; ------------------------------
(defun my/get-wl-clipboard-url ()
  "Return URL from Wayland clipboard if valid."
  (when (executable-find "wl-paste")
    (let ((text (string-trim
                 (shell-command-to-string
                  "wl-paste --no-newline 2>/dev/null"))))
      (when (string-match-p "^https?://" text)
        text))))

(defun my/fetch-page-metadata (url)
  "Return plist (:title :description) from URL."
  (when url
    (require 'url)
    (require 'dom)
    (with-current-buffer (url-retrieve-synchronously url t t 3)
      (goto-char (point-min))
      (re-search-forward "\n\n" nil 'move)
      (let* ((dom (libxml-parse-html-region (point) (point-max)))
             (title-node (car (dom-by-tag dom 'title)))
             (meta-desc (car
                         (seq-filter
                          (lambda (node)
                            (and (eq (dom-tag node) 'meta)
                                 (string= (dom-attr node 'name) "description")))
                          (dom-by-tag dom 'meta)))))
        (list
         :title (when title-node (string-trim (dom-text title-node)))
         :description (when meta-desc (string-trim (or (dom-attr meta-desc 'content) ""))))))))

(defun my/slugify (text)
  "Convert TEXT into a filesystem-friendly slug."
  (let ((slug (downcase (string-trim text))))
    (setq slug (replace-regexp-in-string "[^[:alnum:]]+" "-" slug))
    (setq slug (replace-regexp-in-string "^-+\\|-+$" "" slug))
    (if (string-empty-p slug)
        "web"
      slug)))

(defun my/fetch-page-title (url)
  "Return the title of URL."
  (plist-get (my/fetch-page-metadata url) :title))

(defun my/bookmark-auto-tags (url)
  "Generate tag string from URL domain."
  (when url
    (let* ((parsed (url-generic-parse-url url))
           (host (url-host parsed)))
      (if host
          (format ":%s:" (replace-regexp-in-string "^www\\." "" (car (split-string host "\\."))))
        ":bookmark:"))))

(defun my/org-bookmark-template ()
  "Generate bookmark entry from clipboard with metadata and auto tags."
  (let* ((url (my/get-wl-clipboard-url))
         (meta (when url (my/fetch-page-metadata url)))
         (title (or (plist-get meta :title) url))
         (desc (plist-get meta :description))
         (tags (my/bookmark-auto-tags url)))
    (if url
        (concat
         (format "* [[%s][%s]] %s\n" url title tags)
         (format "  %s\n" (format-time-string "[%Y-%m-%d %a %H:%M]"))
         (when (and desc (> (length desc) 0))
           (format "  %s\n" desc)))
      "* [[%^{URL}][%^{Title}]] :bookmark:\n  %U\n")))

;;; ------------------------------
;;; Grouped Capture Menus
;;; ------------------------------
(defun my/org-capture-grouped ()
  "Select a capture template group."
  (interactive)
  (let ((group (completing-read
                "Choose group: "
                '("Tasks" "Notes" "Bookmarks" "Contacts" "Web" "Elfeed"))))
    (pcase group
      ("Tasks"     (org-capture nil "t"))
      ("Notes"     (org-capture nil "n"))
      ("Bookmarks" (org-capture nil "b"))
      ("Contacts"  (org-capture nil "c"))
      ("Web"   (my/save-url-as-org-web))
      ("Elfeed"    (org-capture nil "e")))))



(defun my/org-capture-grouped-wl ()
  "Grouped capture using region or Wayland clipboard for %i."
  (interactive)
  (require 'org-setup)
  (let* ((region-text (when (use-region-p)
                        (prog1
                            (buffer-substring-no-properties
                             (region-beginning)
                             (region-end))
                          (deactivate-mark))))
         (use-clipboard (and (not region-text)
                             (y-or-n-p "Use Wayland clipboard? ")))
         (wl-text (when (and use-clipboard
                             (executable-find "wl-paste"))
                    (string-trim
                     (shell-command-to-string
                      "wl-paste --no-newline --primary 2>/dev/null"))))
         (initial (or region-text wl-text "")))

    (setq org-capture-initial initial)
    (my/org-capture-grouped)))



;;; ------------------------------
;;; Cleanup Org Capture Buffers
;;; ------------------------------

(defun my/org-kill-capture-file-buffers ()
  "Kill org file buffers opened during capture."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and buffer-file-name
                 (string-prefix-p
                  (expand-file-name "~/org/")
                  buffer-file-name))
        (kill-buffer buf)))))

(add-hook 'org-capture-after-finalize-hook
          #'my/org-kill-capture-file-buffers)

(add-hook 'org-capture-kill-hook
          #'my/org-kill-capture-file-buffers)

;;; ------------------------------
;;; Save URL as Org Web
;;; ------------------------------
(defun my/save-url-as-org-web ()
  "Fetch URL from clipboard or prompt, convert via readable + pandoc, save in Web dir."
  (interactive)
  (unless (executable-find "pandoc") (user-error "Pandoc is not installed"))
  (unless (executable-find "readable") (user-error "Readable CLI is not installed"))
  (let* ((url (or (my/get-wl-clipboard-url) (read-string "URL: "))))
    (unless (string-match-p "^https?://" url) (user-error "Not a valid URL"))
    (message "Fetching web-page...")
    (let* ((title (or (my/fetch-page-title url) "web-page"))
           (slug (my/slugify title))
           (date (format-time-string "%Y-%m-%d"))
           (filename (format "%s-%s.org" date slug))
           (filepath (expand-file-name filename my/org-web-dir))
           (domain (url-host (url-generic-parse-url url)))
           (tag (when domain (format ":%s:" (replace-regexp-in-string "^www\\." "" (car (split-string domain "\\."))))))
           (tmp-html (string-trim (shell-command-to-string (concat "readable " url))))
           (pandoc-buf (generate-new-buffer "*pandoc-org*"))
           (web-buf (find-file-noselect filepath)))
      ;; Convert HTML to Org
      (with-temp-buffer
        (insert tmp-html)
        (call-process-region (point-min) (point-max) "pandoc" t pandoc-buf nil "-f" "html" "-t" "org"))
      ;; Write Org file
      (with-current-buffer web-buf
        (erase-buffer)
        (insert "#+title: " title "\n")
        (insert "#+date: " date "\n")
        (insert "#+source: " url "\n")
        (when tag (insert "#+filetags: " tag "\n"))
        (insert "\n")
        (insert-buffer-substring pandoc-buf)
        (save-buffer))
      (kill-buffer pandoc-buf)
      (switch-to-buffer web-buf)
      (message "Web-Page saved: %s" filename))))

;;; ------------------------------
;;; Org Super Agenda (Deferred)
;;; ------------------------------
(use-package! org-super-agenda
  :defer t
  :commands org-super-agenda-mode
  :init
  (setq org-super-agenda-groups
        '((:name "TODOS" :priority "A|B|C" :todo t)
          (:name "HABITS" :tag "habit" :order 2)
          (:name "BIRTHDAYS" :property "BIRTHDAY" :order 3)
          (:name "NOTES TO REVIEW" :tag "review" :order 5))))

(setq org-agenda-custom-commands
      '(("D" "Super Dashboard"
         ((agenda "" ((org-agenda-span 'week)
                      (org-agenda-start-on-weekday nil)
                      (org-agenda-time-grid nil)
                      (org-agenda-current-time-string "⏰ now")))
          (alltodo "" ((org-agenda-overriding-header "All TODOS:\n")
                      (org-super-agenda-groups
                       '((:name "High Priority" :priority "A")
                         (:name "Medium Priority" :priority "B")
                         (:name "Low Priority" :priority "C")))))))))

;;; ------------------------------
;;; Org Keybindings
;;; ------------------------------
(after! org
  (map! :leader
        (:prefix ("n" . "capture")
         :desc "Grouped Org Capture Menu" "n" #'my/org-capture-grouped
         :desc "Capture Bookmark Directly" "b" #'(lambda () (interactive) (org-capture nil "b"))
         :desc "Super Dashboard"           "d" #'(lambda () (interactive) (org-agenda nil "D"))
         :desc "All TODOs"                 "t" #'org-todo-list
         :desc "Agenda View"               "a" #'org-agenda))

  (map! :leader
        (:prefix ("r" . "review")
         :desc "Org Quick Review Dashboard" "q" #'my/org-quick-review))

  ;; Clocking
  (map! :leader
        (:prefix ("c" . "clock")
         :desc "Clock in"     "i" #'org-clock-in
         :desc "Clock out"    "o" #'org-clock-out
         :desc "Clock cancel" "c" #'org-clock-cancel))

  ;; Refile shortcut
  (define-key org-mode-map (kbd "C-c C-r") #'org-refile))

(provide 'org-setup)
