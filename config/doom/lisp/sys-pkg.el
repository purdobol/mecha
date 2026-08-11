;;; sys-pkg.el --- Lazy-loaded Doom system package manager -*- lexical-binding: t; -*-

;;;###autoload
(defvar my/sys-pkg-default-manager nil
  "Default system package manager. If nil, auto-detect yay > pacman > apt > brew.")

;;;###autoload
(defvar my/sys-pkg-default-exec-mode 'async-buffer
  "Execution mode: 'silent, 'async-buffer, or 'sync-buffer.")

;;; --------------------------------------------------
;;; Autoload interactive commands
;;; --------------------------------------------------

;;;###autoload
(defun my/sys-package-manager ()
  "Interactive system package manager interface."
  (interactive)
  (require 'sys-pkg)  ;; lazy-load helpers
  (my/sys-package-manager--impl))

;;;###autoload
(defun my/sys-pkg-multi-operation ()
  "Install or remove multiple packages at once."
  (interactive)
  (require 'sys-pkg)  ;; lazy-load helpers
  (my/sys-pkg-multi-operation--impl))

;;; --------------------------------------------------
;;; Internal implementations (not autoloaded directly)
;;; --------------------------------------------------
;; These are prefixed with --impl and are only loaded when required

(eval-when-compile
  (defvar sys-pkg--loaded nil))

(unless sys-pkg--loaded
  (setq sys-pkg--loaded t)

  ;; ------------------------
  ;; Manager Detection
  ;; ------------------------
  (defun my/sys-pkg-detect-manager ()
    "Detect the system package manager."
    (or my/sys-pkg-default-manager
        (cond
         ((executable-find "yay") "yay")
         ((executable-find "pacman") "pacman")
         ((executable-find "apt") "apt")
         ((executable-find "brew") "brew")
         (t (user-error "No supported package manager found")))))

  ;; ------------------------
  ;; Command Runner
  ;; ------------------------
  (defun my/sys-pkg-run (cmd &optional mode)
    "Run system package CMD in MODE ('silent, 'async-buffer, 'sync-buffer)."
    (let ((mode (or mode my/sys-pkg-default-exec-mode)))
      (pcase mode
        ('silent
         (start-process "pkg-cmd" nil shell-file-name "-c" cmd)
         (message "Running: %s..." cmd))
        ('async-buffer
         (async-shell-command cmd "*System Package Output*"))
        ('sync-buffer
         (shell-command cmd "*System Package Output*")))))

  ;; ------------------------
  ;; Package Listing
  ;; ------------------------
  (defun my/sys-pkg-list (manager &optional search-installed)
    "List or search packages for MANAGER. If SEARCH-INSTALLED is non-nil, list installed packages."
    (cond
     ;; Installed packages
     (search-installed
      (mapcar
       (lambda (line)
         (let ((pkg (car (split-string line " "))))
           (cons pkg pkg)))
       (split-string
        (shell-command-to-string
         (if (string= manager "yay")
             "yay -Q"
           (format "%s -Q" manager)))
        "\n" t)))

     ;; Search (yay / pacman)
     ((member manager '("yay" "pacman"))
      (let* ((query (read-string "Search package: "))
             (cmd (format "%s -Ss %s" manager query))
             (lines (split-string (shell-command-to-string cmd) "\n" t))
             official aur
             last-pkg last-display last-repo)
        (dolist (line lines)
          (if (string-match "^\\([^ ]+/[^ ]+\\).*" line)
              ;; Package line
              (progn
                (when last-pkg
                  (if (eq last-repo 'official)
                      (setq official (append official
                                             (list (cons last-display last-pkg))))
                    (setq aur (append aur
                                      (list (cons last-display last-pkg))))))
                (setq last-pkg (match-string 1 line))
                (setq last-repo
                      (if (string-match-p
                           "^\\(core\\|extra\\|community\\|multilib\\)/"
                           last-pkg)
                          'official
                        'aur))
                (setq last-display last-pkg))
            ;; Description line
            (when (and last-pkg (string-match-p "^\\s-+" line))
              (setq last-display
                    (format "%s — %s"
                            last-pkg
                            (string-trim line))))))
        ;; push final package
        (when last-pkg
          (if (eq last-repo 'official)
              (setq official (append official
                                     (list (cons last-display last-pkg))))
            (setq aur (append aur
                              (list (cons last-display last-pkg))))))
        ;; Official first
        (append official aur))
      )
     (t (user-error "Unsupported manager: %s" manager))))

  ;; ------------------------
  ;; Main interactive implementation
  ;; ------------------------
  (defun my/sys-package-manager--impl ()
    "Internal impl for interactive package manager."
    (let* ((manager (my/sys-pkg-detect-manager))
           (operation
            (completing-read "Mode: "
                             '("installed" "search/install" "upgrade all")
                             nil t)))
      ;; Upgrade all
      (when (string= operation "upgrade all")
        (my/sys-pkg-run
         (cond
          ((string= manager "yay") "yay -Syu")
          ((string= manager "pacman") "sudo pacman -Syu")
          ((string= manager "apt") "pkexec apt update && pkexec apt upgrade -y")
          ((string= manager "brew") "brew update && brew upgrade"))))
      ;; Installed
      (when (string= operation "installed")
        (let* ((candidates (my/sys-pkg-list manager t))
               (selection-display
                (completing-read
                 "Select package: "
                 (mapcar #'car candidates)
                 nil t))
               (selection (cdr (assoc selection-display candidates)))
               (action
                (completing-read "Action: " '("remove" "reinstall" "show info") nil t))
               (cmd (cond
                     ((and (string= manager "yay") (string= action "remove"))
                      (format "yay -R %s" selection))
                     ((and (string= manager "yay") (string= action "reinstall"))
                      (format "yay -S --needed %s" selection))
                     ((and (string= manager "yay") (string= action "show info"))
                      (format "yay -Qi %s" selection))
                     ((and (string= manager "pacman") (string= action "remove"))
                      (format "sudo pacman -R %s" selection))
                     ((and (string= manager "pacman") (string= action "reinstall"))
                      (format "sudo pacman -S --needed %s" selection))
                     ((and (string= manager "pacman") (string= action "show info"))
                      (format "pacman -Qi %s" selection)))))
          (my/sys-pkg-run cmd)))
      ;; Search / install
      (when (string= operation "search/install")
        (let* ((candidates (my/sys-pkg-list manager nil))
               (selection-display
                (completing-read "Select package: " (mapcar #'car candidates) nil t))
               (selection (cdr (assoc selection-display candidates))))
          (my/sys-pkg-run (format "%s -S %s" manager selection))))))

  ;; ------------------------
  ;; Multi operation implementation
  ;; ------------------------
  (defun my/sys-pkg-multi-operation--impl ()
    "Internal impl for multi-package operations."
    (let* ((manager (my/sys-pkg-detect-manager))
           (operation (completing-read "Operation: " '("install" "remove") nil t))
           (packages (string-join
                      (split-string
                       (read-string "Packages (comma-separated): ")
                       "," t "[[:space:]]+")
                      " "))
           (cmd (cond
                 ((and (string= manager "yay") (string= operation "install"))
                  (format "yay -S %s" packages))
                 ((and (string= manager "yay") (string= operation "remove"))
                  (format "yay -R %s" packages))
                 ((and (string= manager "pacman") (string= operation "install"))
                  (format "sudo pacman -S %s" packages))
                 ((and (string= manager "pacman") (string= operation "remove"))
                  (format "sudo pacman -R %s" packages)))))
      (my/sys-pkg-run cmd))))


(provide 'sys-pkg)
;;; sys-pkg.el ends here
