;;; lisp/elfeed-setup.el -*- lexical-binding: t; -*-

;;; ============================================================
;;; Elfeed Navigation
;;;
;;; RET  Open entry in browser + mark as read
;;; q    Quit Elfeed completely
;;; a    Show all entries
;;; u    Show unread entries
;;; s    Start a fresh search
;;; /    Start a fresh search
;;; r    Fetch/update feeds
;;; g    Refresh current search
;;; R    Mark selected entry as read
;;; U    Mark ALL entries in current search as read
;;;
;;; Search examples:
;;;
;;;   tag:emacs
;;;       Show entries tagged "emacs"
;;;
;;;   tag:linux
;;;       Show entries tagged "linux"
;;;
;;;   unread
;;;       Show unread entries
;;;
;;;   @2-weeks-ago
;;;       Show entries from the last two weeks
;;;
;;;   unread tag:emacs
;;;       Show unread Emacs entries
;;;
;;;   tag:emacs +unread
;;;       Another way to show unread Emacs entries
;;;
;;;   !unread
;;;       Show read entries
;;;
;;;   from:arstechnica.com
;;;       Show entries from a particular feed/source
;;;
;;;   tag:emacs unread
;;;       Combine search terms
;;;
;;; The "s" and "/" bindings start a completely fresh filter.
;;; They do NOT preload the current Elfeed filter.
;;;
;;; All keybindings below are LOCAL to Elfeed search buffers.
;;; No global Consult, Doom, or Emacs keybindings are changed.
;;; ============================================================

(after! elfeed

;; ==========================================================
;; Elfeed-org
;; ==========================================================

(setq rmh-elfeed-org-files
'("~/org/elfeed.org"))

(require 'elfeed-org)
(elfeed-org)

;; ==========================================================
;; Custom Entry Opening
;; ==========================================================

(defun my/elfeed-open-in-browser ()
"Open selected entry in browser and mark it as read."
(interactive)


(let ((entry
       (elfeed-search-selected :single)))

  (when entry
    (elfeed-search-browse-url)

    (elfeed-untag entry 'unread)

    (elfeed-search-update-entry entry))))


;; ==========================================================
;; Quit Elfeed
;; ==========================================================

(defun my/elfeed-quit ()
"Quit Elfeed and kill its buffers."
(interactive)


(dolist (buffer-name
         '("*elfeed-search*"
           "*elfeed-log*"
           "*elfeed-entry*"))

  (when (get-buffer buffer-name)
    (kill-buffer buffer-name)))

(delete-other-windows))


;; ==========================================================
;; Show All Entries
;; ==========================================================

(defun my/elfeed-show-all ()
"Show all Elfeed entries from the last year."
(interactive)


(elfeed-search-set-filter
 "@1-year-ago"))


;; ==========================================================
;; Show Unread Entries
;; ==========================================================

(defun my/elfeed-show-unread ()
"Show unread Elfeed entries from the last year."
(interactive)


(elfeed-search-set-filter
 "@1-year-ago +unread"))


;; ==========================================================
;; Fresh Elfeed Search
;; ==========================================================

(defun my/elfeed-search ()
"Prompt for a completely fresh Elfeed search filter."
(interactive)


(let ((filter
       (read-string "Elfeed filter: ")))

  (elfeed-search-set-filter filter)))


;; ==========================================================
;; Mark Selected Entry as Read
;; ==========================================================

(defun my/elfeed-mark-current-read ()
"Mark the selected Elfeed entry as read."
(interactive)


(let ((entry
       (elfeed-search-selected :single)))

  (when entry

    (elfeed-untag entry 'unread)

    (elfeed-search-update-entry entry))))


;; ==========================================================
;; Mark ALL Entries in Current Search as Read
;; ==========================================================

(defun my/elfeed-mark-search-read ()
"Mark all unread entries in the current Elfeed search as read."
(interactive)


(let ((count 0))

  (dolist
      (entry
       (elfeed-search-entries elfeed-search-filter))

    (when (elfeed-tagged-p 'unread entry)

      (elfeed-untag entry 'unread)

      (setq count
            (1+ count))))

  ;; Elfeed 4.x:
  ;; revert-buffer replaces the obsolete
  ;; elfeed-search-update--force.

  (revert-buffer nil t)

  (message
   "Marked %d unread entries as read."
   count)))


;; ==========================================================
;; Refresh Current Search
;; ==========================================================

(defun my/elfeed-refresh-search ()
"Refresh the current Elfeed search."
(interactive)


;; Elfeed 4.x uses revert-buffer.
(revert-buffer nil t))


;; ==========================================================
;; Reset Elfeed Database
;; ==========================================================

(defun my/elfeed-reset-database ()
"Completely reset Elfeed's database."
(interactive)


(when
    (yes-or-no-p
     "Delete ALL Elfeed history and start fresh? ")

  ;; Close database if supported.
  (when (fboundp 'elfeed-db-close)
    (elfeed-db-close))

  ;; Find the configured database directory.
  (let ((db-dir
         (expand-file-name
          elfeed-db-directory)))

    (message
     "Deleting Elfeed database: %s"
     db-dir)

    ;; Delete database on disk.
    (when (file-directory-p db-dir)
      (delete-directory db-dir t))

    ;; Recreate empty database directory.
    (make-directory db-dir t)

    ;; Clear in-memory database variables if present.
    (when (boundp 'elfeed-db)
      (setq elfeed-db nil))

    (when (boundp 'elfeed-db-entries)
      (setq elfeed-db-entries nil))

    (message
     "Elfeed database reset: %s"
     db-dir))))


;; ==========================================================
;; Feed Capture
;;
;; Adds feeds through Org Capture.
;;
;; The function does NOT modify elfeed.org directly.
;; It returns an Org entry which Org Capture inserts.
;;
;; Clipboard URL is used automatically when available.
;;
;; A normal webpage URL is accepted. The function attempts
;; to discover its RSS/Atom feed automatically.
;;
;; Category selection is handled by org-setup.el.
;; ==========================================================

;; ----------------------------------------------------------
;; Clipboard
;; ----------------------------------------------------------

(defun my/elfeed-feed-url-from-clipboard ()
"Return an HTTP(S) URL from the Wayland clipboard."


(when (executable-find "wl-paste")

  (let ((text
         (string-trim
          (shell-command-to-string
           "wl-paste --no-newline 2>/dev/null"))))

    (when
        (string-match-p
         "\\`https?://"
         text)

      text))))


;; ----------------------------------------------------------
;; Fetch URL
;; ----------------------------------------------------------

(defun my/elfeed-fetch-url-text (url)
"Return the contents of URL as a string."


(require 'url)

(with-current-buffer
    (url-retrieve-synchronously
     url
     t
     t
     10)

  (goto-char (point-min))

  (re-search-forward
   "\n\n"
   nil
   'move)

  (buffer-substring-no-properties
   (point)
   (point-max))))


;; ----------------------------------------------------------
;; Discover RSS / Atom Feed
;; ----------------------------------------------------------

(defun my/elfeed-discover-feed-url (url)
"Return a discovered RSS/Atom URL for URL.

If URL already looks like a feed, return it unchanged."


(if
    (string-match-p
     "\\(\\.xml\\|\\.rss\\|\\.atom\\|/feed\\|/rss\\|/atom\\)"
     (downcase url))

    url

  (condition-case nil

      (let ((html
             (my/elfeed-fetch-url-text url))
            feed)

        ;; Look for an RSS/Atom <link>.
        (when
            (string-match
             "<link[^>]+\\(?:type=[\"']\\(?:application/rss+xml\\|application/atom+xml\\)[\"'][^>]*\\|rel=[\"'][^\"']*alternate[^\"']*[\"'][^>]*\\)"
             html)

          (let ((tag
                 (match-string 0 html)))

            (when
                (string-match
                 "href=[\"']\\([^\"']+\\)[\"']"
                 tag)

              (setq feed
                    (match-string 1 tag)))))

        ;; Resolve relative feed URLs.
        (when feed

          (require 'url-parse)

          (setq feed
                (url-expand-file-name
                 feed
                 (url-generic-parse-url url))))

        feed)

    (error nil))))


;; ----------------------------------------------------------
;; Feed Title
;; ----------------------------------------------------------

(defun my/elfeed-feed-title (url)
"Return the title of the feed at URL."


(condition-case nil

    (let ((xml
           (my/elfeed-fetch-url-text url)))

      (or

       ;; RSS
       (when
           (string-match
            "<channel[^>]*>.*?<title[^>]*>\\([^<]+\\)"
            xml)

         (string-trim
          (match-string 1 xml)))

       ;; Atom
       (when
           (string-match
            "<feed[^>]*>.*?<title[^>]*>\\([^<]+\\)</title>"
            xml)

         (string-trim
          (match-string 1 xml)))

       ;; Generic webpage title fallback.
       (when
           (string-match
            "<title[^>]*>\\([^<]+\\)</title>"
            xml)

         (string-trim
          (match-string 1 xml)))))

  (error nil)))


;; ==========================================================
;; Elfeed Feed Capture
;; ==========================================================

(defun my/elfeed-capture-feed ()
"Return an Org entry for a feed from clipboard or prompt."


(let* ((input
        (or
         (my/elfeed-feed-url-from-clipboard)
         (read-string
          "Feed or webpage URL: ")))

       ;; If this is a normal webpage, try to discover
       ;; its RSS/Atom feed.
       (feed-url
        (or
         (my/elfeed-discover-feed-url input)
         input))

       ;; Get the feed title.
       (title
        (or
         (my/elfeed-feed-title feed-url)
         feed-url)))

  (unless
      (string-match-p
       "\\`https?://"
       feed-url)

    (user-error
     "Not a valid HTTP(S) URL"))

  (message
   "Feed: %s"
   title)

  ;; Return Org text for org-capture.
  (format
   "*** [[%s][%s]] :feed:\n"
   feed-url
   (replace-regexp-in-string
    "[\n\r]"
    " "
    title))))


;; ==========================================================
;; Elfeed Search Keybindings
;; ==========================================================

(after! elfeed-search


;; Open selected entry.
(define-key
  elfeed-search-mode-map
  (kbd "RET")
  #'my/elfeed-open-in-browser)

;; Quit Elfeed.
(define-key
  elfeed-search-mode-map
  (kbd "q")
  #'my/elfeed-quit)

;; Show all entries.
(define-key
  elfeed-search-mode-map
  (kbd "a")
  #'my/elfeed-show-all)

;; Show unread entries.
(define-key
  elfeed-search-mode-map
  (kbd "u")
  #'my/elfeed-show-unread)

;; Fresh search.
(define-key
  elfeed-search-mode-map
  (kbd "s")
  #'my/elfeed-search)

;; Fresh search alternative.
(define-key
  elfeed-search-mode-map
  (kbd "/")
  #'my/elfeed-search)

;; Fetch new feeds.
(define-key
  elfeed-search-mode-map
  (kbd "r")
  #'elfeed-search-fetch)

;; Refresh current search.
(define-key
  elfeed-search-mode-map
  (kbd "g")
  #'my/elfeed-refresh-search)

;; Mark current entry as read.
(define-key
  elfeed-search-mode-map
  (kbd "R")
  #'my/elfeed-mark-current-read)

;; Mark ALL entries in current search as read.
(define-key
  elfeed-search-mode-map
  (kbd "U")
  #'my/elfeed-mark-search-read)))


(provide 'elfeed-setup)
