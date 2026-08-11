;;; mechanoonna-tomorrow-theme.el --- Tomorrow Night + Mechanoonna -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Tomorrow Night's semantic face structure with a restrained,
;; slightly more saturated Mechanoonna-inspired palette.
;;
;; Semantic roles:
;;
;;   red    = errors / destructive states
;;   orange = functions / operators / warnings
;;   yellow = variables / constants
;;   green  = keywords / success / additions
;;   aqua   = strings / informational
;;   blue   = types / numbers / completion
;;   purple = builtins / metadata / documentation
;;
;; Red is deliberately NOT used as a general syntax color.
;; A muted terracotta is used for the normal red semantic role,
;; while the stronger Mechanoonna red is reserved for actual errors
;; and destructive states.
;;
;;; Code:

(require 'color-theme-sanityinc-tomorrow)

(deftheme mechanoonna-tomorrow
  "Tomorrow Night with a slightly more saturated Mechanoonna palette.")


;; ============================================================================
;; Palette
;; ============================================================================

(let ((color-theme-sanityinc-tomorrow-colors
       '((night
          . ((background     . "#1c1b19")
             (alt-background . "#242321")
             (current-line   . "#292724")
             (selection      . "#514d47")
             (foreground     . "#f0e4c5")
             (comment        . "#70675b")

             ;; ----------------------------------------------------------------
             ;; Semantic colors
             ;; ----------------------------------------------------------------

             ;; Errors / destructive states.
             ;;
             ;; Kept muted here so ordinary source code doesn't become red.
             (red            . "#9a6b52")

             ;; Functions / operators / warnings.
             (orange         . "#d08a4f")

             ;; Variables / constants / emphasis.
             (yellow         . "#dfc36d")

             ;; Keywords / success / additions.
             (green          . "#a9a15f")

             ;; Strings / informational.
             (aqua           . "#d0b886")

             ;; Types / numbers / completion.
             ;;
             ;; Deliberately restrained rather than using a conventional blue.
             (blue           . "#96928a")

             ;; Builtins / metadata / documentation.
             (purple         . "#aa9586"))))))


  ;; ==========================================================================
  ;; Generate the complete Tomorrow Night face set
  ;; ==========================================================================

  ;;
  ;; Use Tomorrow's own face definitions rather than recreating them.
  ;;
  ;; This preserves the semantic relationships from the original theme:
  ;;
  ;;   font-lock
  ;;   Magit
  ;;   Org
  ;;   Flycheck / Flymake
  ;;   diff-mode
  ;;   compilation
  ;;   completion
  ;;   vterm
  ;;   rainbow-delimiters
  ;;   ERC
  ;;   Gnus
  ;;   eshell
  ;;   etc.
  ;;

  (color-theme-sanityinc-tomorrow--with-colors
   'night

   (apply #'custom-theme-set-faces
          'mechanoonna-tomorrow
          (color-theme-sanityinc-tomorrow--face-specs))


   ;; ==========================================================================
   ;; Variables configured by Tomorrow
   ;; ==========================================================================

   (custom-theme-set-variables
    'mechanoonna-tomorrow

    ;; Frame background mode.
    `(frame-background-mode ',background-mode)

    ;; Beacon follows the semantic error/accent color.
    `(beacon-color ,red)

    ;; Fill-column-indicator.
    `(fci-rule-color ,contrast-bg)

    ;; --------------------------------------------------------------------------
    ;; VC annotate colors
    ;; --------------------------------------------------------------------------

    ;; Keep the same semantic progression as Tomorrow,
    ;; but use our Mechanoonna palette.
    `(vc-annotate-color-map
      '((20  . ,red)
        (40  . ,orange)
        (60  . ,yellow)
        (80  . ,green)
        (100 . ,aqua)
        (120 . ,blue)
        (140 . ,purple)
        (160 . ,red)
        (180 . ,orange)
        (200 . ,yellow)
        (220 . ,green)
        (240 . ,aqua)
        (260 . ,blue)
        (280 . ,purple)
        (300 . ,red)
        (320 . ,orange)
        (340 . ,yellow)
        (360 . ,green)))

    `(vc-annotate-very-old-color nil)

    `(vc-annotate-background nil)

    ;; Keep Tomorrow's modeline color behaviour.
    `(flycheck-color-mode-line-face-to-color
      'mode-line-buffer-id)

    ;; --------------------------------------------------------------------------
    ;; ANSI colors for terminal buffers
    ;; --------------------------------------------------------------------------

    `(ansi-color-names-vector
      (vector
       ,background
       ,red
       ,green
       ,yellow
       ,blue
       ,purple
       ,aqua
       ,foreground))

    ;; Window dividers are handled in config.el.
    `(window-divider-mode nil))))


;; ============================================================================
;; Selected UI faces
;;
;; These are theme-level semantic refinements.
;;
;; General UI chrome such as line numbers, modeline and window dividers
;; is intentionally handled separately in config.el.
;; ============================================================================

(custom-theme-set-faces
 'mechanoonna-tomorrow

 ;; ---------------------------------------------------------------------------
 ;; Base
 ;; ---------------------------------------------------------------------------

 '(default
   ((t (:background "#1c1b19"
        :foreground "#f0e4c5"))))

 ;; ---------------------------------------------------------------------------
 ;; Cursor
 ;; ---------------------------------------------------------------------------

 '(cursor
   ((t (:background "#d08a4f"))))

 ;; ---------------------------------------------------------------------------
 ;; Selection
 ;; ---------------------------------------------------------------------------

 '(region
   ((t (:background "#514d47"
        :foreground "#f0e4c5"))))


;; ---------------------------------------------------------------------------
;; Current line
;; ---------------------------------------------------------------------------

'(hl-line
  ((t (:background "#292724"))))


;; ---------------------------------------------------------------------------
;; Search
;; ---------------------------------------------------------------------------


 '(isearch
   ((t (:foreground "#1c1b19"
        :background "#dfc36d"
        :weight bold))))

 '(isearch-fail
   ((t (:foreground "#f0e4c5"
        :background "#9a6b52"
        :weight bold))))

 '(lazy-highlight
   ((t (:foreground "#f0e4c5"
        :background "#514d47"))))

 ;; ---------------------------------------------------------------------------
 ;; Links
 ;; ---------------------------------------------------------------------------

 '(link
   ((t (:foreground "#d0b886"
        :underline t))))

 ;; ---------------------------------------------------------------------------
 ;; Actual errors
 ;;
 ;; Here we intentionally bring back Mechanoonna's stronger red.
 ;; ---------------------------------------------------------------------------

 '(error
   ((t (:foreground "#c5564a"
        :weight bold))))

 '(flycheck-error
   ((t (:foreground "#c5564a"
        :underline t))))

 '(flymake-error
   ((t (:foreground "#c5564a"
        :underline t))))

 '(compilation-error
   ((t (:foreground "#c5564a"
        :weight bold))))

 ;; ---------------------------------------------------------------------------
 ;; Diff / destructive changes
 ;; ---------------------------------------------------------------------------

 '(diff-removed
   ((t (:foreground "#c5564a"))))

 '(diff-changed
   ((t (:foreground "#d08a4f"))))

 '(diff-added
   ((t (:foreground "#a9a15f"))))

 '(magit-diff-removed
   ((t (:foreground "#c5564a"))))

 '(magit-diff-added
   ((t (:foreground "#a9a15f")))))


;; ============================================================================
;; Stronger semantic colors for selected UI elements
;; ============================================================================

(custom-theme-set-faces
 'mechanoonna-tomorrow

 ;; ---------------------------------------------------------------------------
 ;; Org headings
 ;; ---------------------------------------------------------------------------

 '(org-level-1
   ((t (:foreground "#dfc36d"
        :weight bold))))

 '(org-level-2
   ((t (:foreground "#d0b886"
        :weight bold))))

 '(org-level-3
   ((t (:foreground "#a9a15f"
        :weight bold))))

 '(org-level-4
   ((t (:foreground "#aa9586"
        :weight bold))))

 ;; ---------------------------------------------------------------------------
 ;; Org links
 ;; ---------------------------------------------------------------------------

 '(org-link
   ((t (:foreground "#d0b886"
        :underline t))))

 ;; ---------------------------------------------------------------------------
 ;; Org TODO / DONE
 ;; ---------------------------------------------------------------------------

 '(org-todo
   ((t (:foreground "#d08a4f"
        :weight bold))))

 '(org-done
   ((t (:foreground "#a9a15f"
        :weight bold))))

 ;; ---------------------------------------------------------------------------
 ;; Magit
 ;; ---------------------------------------------------------------------------

 '(magit-section-heading
   ((t (:foreground "#dfc36d"
        :weight bold))))

 '(magit-branch-local
   ((t (:foreground "#a9a15f"))))

 '(magit-branch-remote
   ((t (:foreground "#d0b886"))))

 ;; ---------------------------------------------------------------------------
 ;; Rainbow delimiters
 ;; ---------------------------------------------------------------------------

 '(rainbow-delimiters-depth-1-face
   ((t (:foreground "#dfc36d"))))

 '(rainbow-delimiters-depth-2-face
   ((t (:foreground "#d0b886"))))

 '(rainbow-delimiters-depth-3-face
   ((t (:foreground "#a9a15f"))))

 '(rainbow-delimiters-depth-4-face
   ((t (:foreground "#aa9586"))))

 '(rainbow-delimiters-depth-5-face
   ((t (:foreground "#d08a4f"))))

 '(rainbow-delimiters-depth-6-face
   ((t (:foreground "#96928a")))))


;; ============================================================================
;; Stronger red only for genuinely destructive/error states
;; ============================================================================

(custom-theme-set-faces
 'mechanoonna-tomorrow

 '(diff-refine-removed
   ((t (:foreground "#c5564a"
        :weight bold))))

 '(magit-diff-removed-highlight
   ((t (:foreground "#c5564a"
        :background "#292724"))))

 '(flycheck-fringe-error
   ((t (:foreground "#c5564a"))))

 '(flymake-error-echo
   ((t (:foreground "#c5564a"
        :weight bold)))))




;; ============================================================================
;; UI faces
;; ============================================================================

(custom-theme-set-faces
 'mechanoonna-tomorrow

 ;; --------------------------------------------------------------------------
 ;; Window dividers
 ;; --------------------------------------------------------------------------

 '(vertical-border
   ((t (:foreground "#1c1b19"
        :background "#1c1b19"))))

 '(window-divider
   ((t (:foreground "#1c1b19"))))

 '(window-divider-first-pixel
   ((t (:foreground "#1c1b19"))))

 '(window-divider-last-pixel
   ((t (:foreground "#1c1b19"))))


 ;; --------------------------------------------------------------------------
 ;; Line numbers
 ;; --------------------------------------------------------------------------

 '(line-number
   ((t (:foreground "#6b655c"
        :background "#171614"))))

 '(line-number-current-line
   ((t (:foreground "#f0e4c5"
        :background "#171614"
        :weight bold))))


 ;; --------------------------------------------------------------------------
 ;; Modeline
 ;; --------------------------------------------------------------------------

 '(mode-line
   ((t (:foreground "#f0e4c5"
        :background "#242321"
        :box nil
        :weight normal))))

 '(mode-line-inactive
   ((t (:foreground "#6b655c"
        :background "#1c1b19"
        :box nil
        :weight normal))))

 '(mode-line-buffer-id
   ((t (:foreground "#d8c486"
        :background "#242321"
        :weight bold
        :box nil))))


 ;; --------------------------------------------------------------------------
 ;; Org drawers / properties
 ;; --------------------------------------------------------------------------

 '(org-drawer
   ((t (:foreground "#96928a"))))

 '(org-property-value
   ((t (:foreground "#96928a"))))


 ;; --------------------------------------------------------------------------
 ;; Dirvish
 ;; --------------------------------------------------------------------------

 '(dirvish-file-time
   ((t (:foreground "#70675b"))))


 ;; --------------------------------------------------------------------------
 ;; Nerd Icons
 ;; --------------------------------------------------------------------------

 '(nerd-icons-purple
   ((t (:foreground "#cbb994"))))

 '(nerd-icons-blue
   ((t (:foreground "#908d88"))))

 '(nerd-icons-cyan
   ((t (:foreground "#cbb994"))))

 '(nerd-icons-green
   ((t (:foreground "#a89972"))))

 '(nerd-icons-yellow
   ((t (:foreground "#d8c486"))))

 '(nerd-icons-orange
   ((t (:foreground "#c58a55"))))

 '(nerd-icons-red
   ((t (:foreground "#9a6b52")))))



(provide-theme 'mechanoonna-tomorrow)

;;; mechanoonna-tomorrow-theme.el ends here
