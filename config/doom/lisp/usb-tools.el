;;; usb-tools.el --- USB mount/unmount utilities -*- lexical-binding: t; -*-

;;;###autoload
(defun my/usb-partitions-consult ()
  "Return a list of USB partitions as strings, and a mapping to device info."
  (let ((lines (split-string
                (shell-command-to-string
                 "lsblk -o NAME,LABEL,TYPE,RM,MOUNTPOINT -nr") "\n" t))
        candidates
        mapping)
    (dolist (line lines)
      (let* ((parts (split-string line " +" t))
             (device (or (nth 0 parts) ""))
             (label (or (nth 1 parts) "NoLabel"))
             (type (or (nth 2 parts) ""))
             (rm (or (nth 3 parts) "0"))
             (mp (or (nth 4 parts) "")))
        ;; Only USB partitions
        (when (and (string= type "part")
                   (= (string-to-number rm) 1))
          (let ((display (format "%s (%s) %s"
                                 label device
                                 (if (string-empty-p mp) "unmounted" mp))))
            (push display candidates)
            (push (cons display (list device mp)) mapping)))))
    (list (nreverse candidates) (nreverse mapping)))) ;; return both

;;;###autoload
(defun my/usb-mount-unmount ()
  "Mount or unmount a USB partition using Consult/Vertico safely.
Suppresses buffers and handles busy drives after visiting in Dirvish."
  (interactive)
  (require 'usb-tools) ;; ensure helpers loaded
  (let* ((usb-data (my/usb-partitions-consult))
         (candidates (car usb-data))
         (mapping (cadr usb-data))
         (selection (consult--read candidates
                                   :prompt "Select USB partition: "
                                   :require-match t
                                   :sort nil
                                   :annotate (lambda (entry)
                                               (let ((info (assoc entry mapping))
                                                     mp)
                                                 (setq mp (nth 1 (cdr info)))
                                                 (if (string-empty-p mp)
                                                     "unmounted"
                                                   (format "mounted at %s" mp)))))))
    (when selection
      (let* ((info (assoc selection mapping))
             (device (nth 0 (cdr info)))
             (mp (nth 1 (cdr info)))
             (action (if (string-empty-p mp) "mount" "unmount")))
        ;; If unmounting, first switch to safe dir and kill buffers in USB
        (when (string= action "unmount")
          (when (and (stringp mp)
                     (file-directory-p mp)
                     (string-prefix-p mp default-directory))
            (cd "~"))
          (dolist (buf (buffer-list))
            (when (and (buffer-file-name buf)
                       (string-prefix-p mp (buffer-file-name buf)))
              (kill-buffer buf))))
        ;; Launch mount/unmount asynchronously without opening buffer
        (start-process
         (format "usb-%s" action) nil "udisksctl" action "-b" (format "/dev/%s" device))
        (message "%s /dev/%s..." (capitalize action) device)))))

(provide 'usb-tools)

;;; usb-tools.el ends here
