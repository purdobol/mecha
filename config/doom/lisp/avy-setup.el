;;; avy-setup.el --- Avy configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Avy configuration inspired by:
;; https://karthinks.com/software/avy-can-do-anything/

;;; Code:

;; ============================================================
;; Avy hint keys
;; ============================================================
;;
;; Keep dispatch keys out of the hint keys.
;;
;; Karthik does this so that keys such as k, m, t, z, etc.
;; remain available as Avy actions.
;;
;; ============================================================

(setq avy-keys
      '(?q ?e ?r ?y ?u ?o ?p
        ?a ?s ?d ?f ?g ?h ?j
        ?l ?x ?c ?v ?b
        ?n ?, ?/))


;; ============================================================
;; Avy dispatch actions
;; ============================================================
;;
;; After:
;;
;;   C-. → type search text → dispatch key → Avy hint
;;
;; the dispatch key determines what happens to the target.
;;
;; ============================================================

;; ------------------------------------------------------------
;; Kill
;; ------------------------------------------------------------
;;
;; k → kill word / sexp at target
;;
;; K → kill entire line
;; ------------------------------------------------------------

(defun my/avy-action-kill-whole-line (pt)
  (save-excursion
    (goto-char pt)
    (kill-whole-line))
  (select-window
   (cdr (ring-ref avy-ring 0)))
  t)

(setf (alist-get ?k avy-dispatch-alist)
      #'avy-action-kill-stay

      (alist-get ?K avy-dispatch-alist)
      #'my/avy-action-kill-whole-line)


;; ------------------------------------------------------------
;; Copy
;; ------------------------------------------------------------
;;
;; w → copy word / sexp at target
;;
;; W → copy entire line
;; ------------------------------------------------------------

(defun my/avy-action-copy-whole-line (pt)
  (save-excursion
    (goto-char pt)
    (kill-ring-save
     (line-beginning-position)
     (line-beginning-position 2)))
  (select-window
   (cdr (ring-ref avy-ring 0)))
  t)

(setf (alist-get ?w avy-dispatch-alist)
      #'avy-action-copy

      (alist-get ?W avy-dispatch-alist)
      #'my/avy-action-copy-whole-line)


;; ------------------------------------------------------------
;; Yank
;; ------------------------------------------------------------
;;
;; y → yank/copy target at point
;;
;; Y → yank entire line
;; ------------------------------------------------------------

(defun my/avy-action-yank-whole-line (pt)
  (my/avy-action-copy-whole-line pt)
  (save-excursion
    (yank))
  t)

(setf (alist-get ?y avy-dispatch-alist)
      #'avy-action-yank

      (alist-get ?Y avy-dispatch-alist)
      #'my/avy-action-yank-whole-line)


;; ------------------------------------------------------------
;; Teleport
;; ------------------------------------------------------------
;;
;; t → move target to current point
;;
;; T → move entire line to current point
;; ------------------------------------------------------------

(defun my/avy-action-teleport-whole-line (pt)
  (my/avy-action-kill-whole-line pt)
  (save-excursion
    (yank))
  t)

(setf (alist-get ?t avy-dispatch-alist)
      #'avy-action-teleport

      (alist-get ?T avy-dispatch-alist)
      #'my/avy-action-teleport-whole-line)


;; ------------------------------------------------------------
;; Zap
;; ------------------------------------------------------------
;;
;; z → kill text from point to target
;; ------------------------------------------------------------

(setf (alist-get ?z avy-dispatch-alist)
      #'avy-action-zap)


;; ------------------------------------------------------------
;; Mark
;; ------------------------------------------------------------
;;
;; m → mark word / sexp at target
;; ------------------------------------------------------------

(setf (alist-get ?m avy-dispatch-alist)
      #'avy-action-mark)


;; ------------------------------------------------------------
;; Mark region to target
;; ------------------------------------------------------------
;;
;; SPC → mark from original point to target
;; ------------------------------------------------------------

(defun my/avy-action-mark-to-char (pt)
  (activate-mark)
  (goto-char pt))

(setf (alist-get ?\s avy-dispatch-alist)
      #'my/avy-action-mark-to-char)


;; ------------------------------------------------------------
;; Spellcheck
;; ------------------------------------------------------------
;;
;; i → ispell target word
;; ------------------------------------------------------------

(setf (alist-get ?i avy-dispatch-alist)
      #'avy-action-ispell)


;; ============================================================
;; Isearch integration
;; ============================================================
;;
;; C-s → search
;; C-. → Avy among the current search matches
;;
;; This is one of the particularly useful ideas from Karthik's
;; article.
;; ============================================================

(after! isearch
  (define-key isearch-mode-map
    (kbd "C-.")
    #'avy-isearch)


  ;; ==========================================================
  ;; Embark integration
  ;; ==========================================================
  ;;
  ;; C-. → filter/select candidate
  ;; o   → Embark action on candidate
  ;;
  ;; This lets Avy find the location while Embark determines
  ;; the semantic target/action.
  ;; ==========================================================

  (when (fboundp #'embark-act)
    (defun my/avy-action-embark (pt)
      (unwind-protect
          (save-excursion
            (goto-char pt)
            (embark-act))
        (select-window
         (cdr (ring-ref avy-ring 0))))
      t)

    (setf (alist-get ?o avy-dispatch-alist)
          #'my/avy-action-embark)))


;;; avy-setup.el ends here
