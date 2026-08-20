;;; tmr-setup.el --- Custom TMR configuration -*- lexical-binding: t; -*-

;;;###autoload
(defun my/tmr-repeat-ack ()
  "Start a TMR timer that requires acknowledgement before each repeat."
  (interactive)
  (require 'tmr)
  (call-interactively #'my/tmr-repeat-ack--real))


(after! tmr

  ;; ============================================================
  ;; State
  ;; ============================================================

  (defvar my/tmr-repeat-ack--timers
    (make-hash-table :test #'eq)
    "TMR timers belonging to serial acknowledgement sequences.")


  ;; ============================================================
  ;; Looping alarm sound
  ;; ============================================================

  (defun my/tmr-repeat-ack--start-sound ()
    "Start looping the TMR alarm sound."
    (when-let ((ffplay (executable-find "ffplay")))
      (start-process
       "tmr-repeat-ack-sound"
       nil
       ffplay
       "-nodisp"
       "-loglevel" "quiet"
       "-loop" "0"
       "-autoexit"
       tmr-sound-file)))

  (defun my/tmr-repeat-ack--stop-sound (process)
    "Stop looping alarm PROCESS."
    (when (process-live-p process)
      (delete-process process)))


  ;; ============================================================
  ;; Completion
  ;; ============================================================

  (defun my/tmr-repeat-ack--finish (timer)
    "Acknowledge TIMER, then start its next repetition."
    (when-let ((state
                (gethash timer
                         my/tmr-repeat-ack--timers)))

      (let ((remaining
             (plist-get state :remaining))
            (duration
             (plist-get state :duration))
            (description
             (plist-get state :description))
            (sound-process
             (my/tmr-repeat-ack--start-sound)))

        ;; TMR has already handled its normal completion:
        ;;
        ;;   - notification
        ;;   - normal alarm sound
        ;;   - completion message
        ;;
        ;; Our looping sound now continues until acknowledgement.

        (unwind-protect
            ;; Wait for acknowledgement.
            (read-from-minibuffer
             (format
              "%s\nAcknowledge with `ack': "
              description))

          ;; ALWAYS stop the looping sound, including C-g.
          (my/tmr-repeat-ack--stop-sound
           sound-process))

        ;; Only after acknowledgement do we start
        ;; the next interval.
        (if (> remaining 1)

            (progn
              ;; Create the next one-shot TMR timer.
              (tmr duration description nil)

              ;; TMR puts the newly-created timer at the
              ;; front of `tmr--timers'.
              (let ((next-timer
                     (car tmr--timers)))

                (puthash
                 next-timer
                 (list
                  :remaining (1- remaining)
                  :duration duration
                  :description description)
                 my/tmr-repeat-ack--timers)))

          ;; Final repetition.
          (remhash
           timer
           my/tmr-repeat-ack--timers)))))


  ;; ============================================================
  ;; Completion hook
  ;; ============================================================

  ;; Run after TMR's normal finished functions.
  ;;
  ;; TMR:
  ;;   notification
  ;;   normal sound
  ;;   message
  ;;
  ;; Then:
  ;;   our looping sound
  ;;   acknowledgement
  ;;   next timer
  ;;
  (add-hook 'tmr-timer-finished-functions
            #'my/tmr-repeat-ack--finish
            90)


  ;; ============================================================
  ;; Real implementation
  ;; ============================================================

  (defun my/tmr-repeat-ack--real
      (duration repeat-count description)
    "Create a serial repeating TMR timer."
    (interactive
     (list
      (tmr--read-duration)
      (tmr-repeat-prompt)
      (tmr--description-prompt)))

    ;; First one-shot timer.
    (tmr duration description nil)

    ;; Register the sequence.
    (puthash
     (car tmr--timers)
     (list
      :remaining repeat-count
      :duration duration
      :description description)
     my/tmr-repeat-ack--timers)))


(provide 'tmr-setup)

;;; tmr-setup.el ends here
