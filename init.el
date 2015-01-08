;;; init.el --- Starting point for Alex Murray's Emacs Configuration

;;; Commentary:
;;

;;; Code:

;; prefer newer non-byte compiled sources to older byte compiled ones
(setq load-prefer-newer t)

;;; Package management
(require 'package)
;; we use use-package to do this for us
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

;; Bootstrap `use-package' from melpa
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; some useful functions for the rest of this init file
(require 'notifications nil t)
(defun apm-notify (msg)
  "Notify user of MSG using desktop notification or (message)."
  (if (fboundp #'notifications-notify)
      (notifications-notify :body msg)
    (message msg)))

(defun apm-camelize (s &optional delim)
  "Convert under_score string S to CamelCase string with optional DELIM."
  (interactive "s")
  (mapconcat 'identity (mapcar
                        #'(lambda (word) (capitalize (downcase word)))
                        (split-string s (if delim delim "_"))) ""))

(when (version< emacs-version "24.4")
  (apm-notify "Emacs version too old - please run 24.4 or newer"))

;;; General settings etc

;; just use y or n not yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; map return to newline and indent
(define-key global-map (kbd "RET") 'newline-and-indent)

;; inhibit startup message and splash screen
(setq inhibit-startup-message t)
;; remove message from initial scratch buffer
(setq initial-scratch-message nil)

;; disable menu, tool and scroll-bars, show time
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode 0))
(display-time-mode 1)
;; Show line column numbers in mode line
(line-number-mode 1)
(column-number-mode 1)

(defun apm-graphic-frame-init ()
  "Initialise properties specific to graphical display."
  (interactive)
  (when (display-graphic-p)
    (setq frame-title-format '(buffer-file-name "%f" ("%b")))
    ;; don't use gtk style tooltips so instead can use pos-tip etc
    (custom-set-variables
     '(x-gtk-use-system-tooltips nil))
    (tooltip-mode -1)
    (mouse-wheel-mode t)
    (blink-cursor-mode -1)
    (if (font-info "Ubuntu Mono")
        (set-face-attribute 'default nil :font "Ubuntu Mono 12")
      (apm-notify "Ubuntu Mono font is not installed."))
    (unless (font-info "FontAwesome")
      (apm-notify "FontAwesome is not installed."))))

;; make sure graphical properties get set on client frames
(add-hook 'find-file-hook 'apm-graphic-frame-init)

(apm-graphic-frame-init)

;; prettify symbols (turn lambda -> λ)
(global-prettify-symbols-mode 1)

;; show colours correctly in shell
(ansi-color-for-comint-mode-on)

;; Use regex searches and replace by default.
(bind-key "C-s" 'isearch-forward-regexp)
(bind-key "C-r" 'isearch-backward-regexp)
(bind-key "M-%" 'query-replace-regexp)
(bind-key "C-M-s" 'isearch-forward)
(bind-key "C-M-r" 'isearch-backward)
(bind-key "C-M-%" 'query-replace)

;; a couple nice definitions taken from emacs-starter-kit
(defun sudo-edit (&optional arg)
  "Open the current buffer (or prompt for file if ARG is non-nill) using sudo to edit as root."
  (interactive "p")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo::" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo::" buffer-file-name))))

(defun lorem ()
  "Insert a lorem ipsum."
  (interactive)
  (insert "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do "
          "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim"
          "ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut "
          "aliquip ex ea commodo consequat. Duis aute irure dolor in "
          "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla "
          "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in "
          "culpa qui officia deserunt mollit anim id est laborum."))

(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a to `smarter-move-beginning-of-line'
(bind-key [remap move-beginning-of-line] 'smarter-move-beginning-of-line)

;;; Packages
(use-package ack-and-a-half
  :ensure t
  :defer t
  :config (progn
            ;; shorter aliases for ack-and-a-half commands
            (defalias 'ack 'ack-and-a-half)
            (defalias 'ack-same 'ack-and-a-half-same)
            (defalias 'ack-find-file 'ack-and-a-half-find-file)
            (defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)))

(use-package ace-jump-mode
  :ensure t
  :bind ("C-c SPC" . ace-jump-mode))

(use-package ace-jump-zap
  :ensure t)

(use-package adaptive-wrap
  :ensure t)

(use-package abbrev
  :diminish abbrev-mode
  :config (progn
            (setq save-abbrevs t)
            (setq-default abbrev-mode t)))

(use-package aggressive-indent
  :ensure t)

(use-package android-mode
  :ensure t
  :defer t
  :config (progn
            ;; change prefix so doesn't conflict with comment-region
            (setq android-mode-sdk-dir "/opt/android-sdk-linux/"
                  android-mode-key-prefix (kbd "C-c C-m")))
  :diminish (android-mode . (concat " " [#xF17B])))

(use-package anaconda-mode
  :ensure t
  :init (progn
          (defun apm-anaconda-mode-setup ()
            "Setup anaconda-mode for python programming."
            ;; turn on anaconda-mode
            (anaconda-mode t)
            ;; integrate into eldoc
            (anaconda-eldoc))

          ;; use anaconda-mode for python
          (add-hook 'python-mode-hook 'apm-anaconda-mode-setup)))

(use-package anzu
  :ensure t
  :diminish anzu-mode
  :init (global-anzu-mode))

(use-package apm-c
  :load-path "lisp/")

(use-package apropos
  :bind ("C-h a" . apropos))

(use-package auctex
  :ensure t
  :mode ("\\.tex\\'" . LaTeX-mode)
  :config (progn
            (setq-default TeX-auto-save t)
            (setq-default TeX-parse-self t)
            (setq-default TeX-PDF-mode t)
            (setq-default TeX-master nil)
            (setq-default reftex-plug-into-AUCTeX t)
            (setq-default TeX-source-specials-view-start-server t))
  :init (progn
          (defun apm-latex-mode-setup ()
            "Tweaks and customisations for LaTeX mode."
            ;; use visual line mode to do soft word wrapping
            (visual-line-mode 1)
            ;; and use adaptive-wrap to 'indent' paragraphs appropriately with visual-line-mode
            (adaptive-wrap-prefix-mode 1)
            ;; Enable flyspell
            (flyspell-mode 1)
            ;; give warning if words misspelled when typing
            (ispell-minor-mode 1)
            ;; use flycheck for on the fly syntax checking
            (flycheck-mode 1)
            ;; smartparens latex support
            (require 'smartparens-latex)
            ;; Enable source-specials for Control-click forward/reverse search.
            (TeX-source-specials-mode 1)
            ;; enable math mode in latex
            (LaTeX-math-mode 1)
            ;; Enable reftex
            (turn-on-reftex))

          (add-hook 'LaTeX-mode-hook 'apm-latex-mode-setup)))

(use-package browse-kill-ring
  :ensure t)

(use-package bs
  :bind ("C-x C-b" . bs-show))

(use-package cc-mode
  :config (progn
            ;; show #if 0 / #endif etc regions in comment face - taken from
            ;; http://stackoverflow.com/questions/4549015/in-c-c-mode-in-emacs-change-face-of-code-in-if-0-endif-block-to-comment-fa
            (defun c-mode-font-lock-if0 (limit)
              "Fontify #if 0 / #endif as comments for c modes etc.
Bound search to LIMIT as a buffer position to find appropriate
code sections."
              (save-restriction
                (widen)
                (save-excursion
                  (goto-char (point-min))
                  (let ((depth 0) str start start-depth)
                    (while (re-search-forward "^\\s-*#\\s-*\\(if\\|else\\|endif\\)" limit 'move)
                      (setq str (match-string 1))
                      (if (string= str "if")
                          (progn
                            (setq depth (1+ depth))
                            (when (and (null start) (looking-at "\\s-+0"))
                              (setq start (match-end 0)
                                    start-depth depth)))
                        (when (and start (= depth start-depth))
                          (c-put-font-lock-face start (match-beginning 0) 'font-lock-comment-face)
                          (setq start nil))
                        (when (string= str "endif")
                          (setq depth (1- depth)))))
                    (when (and start (> depth 0))
                      (c-put-font-lock-face start (point) 'font-lock-comment-face)))))
              nil)

            ;; c-mode and other derived modes (c++, java etc) etc
            (defun apm-c-mode-common-setup ()
              "Tweaks and customisations for all modes derived from c-common-mode."
              ;; set a reasonable fill and comment column
              (setq fill-column 78)
              (setq comment-column 70)
              ;; hide ifdef
              (hide-ifdef-mode 1)
              (eval-after-load 'diminish
                '(diminish 'hide-ifdef-mode))
              (auto-fill-mode 1)
              ;; diminish auto-fill in the modeline to icon from fontawesome
              (eval-after-load 'diminish
                '(diminish 'auto-fill-function (concat " " [#xF036])))
              ;; turn on auto-newline and hungry-delete
              (c-toggle-auto-hungry-state t)
              ;; set auto newline
              (setq c-auto-newline 1)
              ;; enable aggressive indent
              (aggressive-indent-mode 1)
              ;; make underscore a word character so movements across words
              ;; include it - this is the same as vim
              (modify-syntax-entry ?_ "w")
              ;; ensure fill-paragraph takes doxygen @ markers as start of new
              ;; paragraphs properly
              (setq paragraph-start "^[ ]*\\(//+\\|\\**\\)[ ]*\\([ ]*$\\|@param\\)\\|^\f")
              ;; add key-bindings for smartparens hybrid sexps
              (local-set-key (kbd "C-)") 'sp-slurp-hybrid-sexp)
              (local-set-key (kbd "C-<right>") 'sp-slurp-hybrid-sexp)
              (local-set-key (kbd "C-<left>") 'sp-dedent-adjust-sexp)

              ;; set company backends appropriately to prefer smart
              ;; backends over dumb
              (with-eval-after-load 'company
                (unless (executable-find company-clang-executable)
                  (apm-notify "clang not found for company-clang - is it installed?"))
                (setq-local company-backends '((company-clang company-semantic) company-gtags)))

              ;; show #if 0 / #endif etc regions in comment face
              (font-lock-add-keywords
               nil
               '((c-mode-font-lock-if0 (0 font-lock-comment-face prepend))) 'add-to-end))

            (add-hook 'c-mode-common-hook 'apm-c-mode-common-setup)))

(use-package c-eldoc
  :ensure t)

(use-package column-enforce-mode
  :ensure t
  :diminish column-enforce-mode
  :init (global-column-enforce-mode))

(use-package company
  :ensure t
  :defer t
  :idle (global-company-mode t)
  :diminish company-mode
  :config (progn
            ;; Use Company for completion
            (bind-key [remap completion-at-point] #'company-complete company-mode-map)
            ;; some better default values
            (setq company-idle-delay 0.5)
            (setq company-tooltip-limit 10)
            (setq company-minimum-prefix-length 2)

            ;; align annotations in tooltip
            (setq company-tooltip-align-annotations t)

            ;; nicer keybindings
            (define-key company-active-map (kbd "C-n") 'company-select-next)
            (define-key company-active-map (kbd "C-p") 'company-select-previous)
            (define-key company-active-map (kbd "C-d") 'company-show-doc-buffer)
            (define-key company-active-map (kbd "<tab>") 'company-complete)

            ;; put most often used completions at stop of list
            (setq company-transformers '(company-sort-by-occurrence))

            ;; choose better colours for company
            (set-face-attribute 'company-tooltip nil :background "black" :foreground "gray40")
            (set-face-attribute 'company-tooltip-selection nil :inherit 'company-tooltip :background "gray15")
            (set-face-attribute 'company-preview nil :background "black")
            (set-face-attribute 'company-preview-common nil :inherit 'company-preview :foreground "gray40")
            (set-face-attribute 'company-scrollbar-bg nil :inherit 'company-tooltip :background "gray20")
            (set-face-attribute 'company-scrollbar-fg nil :background "gray40")))

(use-package company-anaconda
  (with-eval-after-load 'company
    (add-to-list 'company-backends 'company-anaconda)))

(use-package company-auctex
  :ensure t
  :init (company-auctex-init))

(use-package company-math
  :ensure t)

(use-package compile
  :bind ("C-x C-m" . compile))

(use-package cua-base
  ;; use CUA mode for rectangle selections etc but not copy/paste etc
  :init (cua-selection-mode t))

(use-package cus-edit
  :config (progn
            (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
            ;; load custom but ignore error if doesn't exist
            (load custom-file t)))

;; show suspicious c constructs automatically
(use-package cwarn
  :diminish cwarn-mode
  :init (global-cwarn-mode 1))

(use-package delsel
  ;; enable delete-selection mode to allow replacing selected region
  ;; with new text automatically
  :init (delete-selection-mode 1))

(use-package devhelp
  :load-path "vendor/")

(use-package diff
  ;; default to unified diff
  :config (setq diff-switches "-u"))

(use-package diff-hl
  :ensure t
  :init (global-diff-hl-mode))

(use-package diminish
  :ensure t)

(use-package doxymacs
  :defer t
  :diminish doxymacs-mode
  :config
  :init  (progn
           (defun apm-doxymacs-setup()
             (doxymacs-mode)
             (doxymacs-font-lock))
           ;; enable in c common modes
           (add-hook 'c-mode-common-hook #'apm-doxymacs-setup)))

(use-package dts-mode
  :ensure t)

(use-package ediff
  :config (setq ediff-window-setup-function 'ediff-setup-windows-plain
                ediff-split-window-function 'split-window-horizontally))

(use-package eldoc
  :diminish eldoc-mode
  ;; enable eldoc in eval-expression
  :config (add-hook 'eval-expression-minibuffer-setup-hook #'eldoc-mode))

(use-package electric
  :init (progn
          ;; electric indent and layout modes to make more IDE like
          (electric-indent-mode t)
          (electric-layout-mode t)))

(use-package elisp-slime-nav
  :ensure t
  :diminish elisp-slime-nav-mode
  :init (progn
          (dolist (hook '(emacs-lisp-mode-hook ielm-mode-hook))
            (add-hook hook 'elisp-slime-nav-mode))))

(use-package eshell
  :bind ("C-x m" . eshell)
  :init (progn
          (defun apm-eshell-mode-setup ()
            "Initialise 'eshell-mode'."
            (setq mode-name (concat "e" [#xF120])))

          (add-hook 'eshell-mode-hook 'apm-eshell-mode-setup)))

(use-package ethan-wspace
  :ensure t
  :diminish ethan-wspace-mode
  :config (progn
            ;; ethan-wspace-mode raises lots of warnings if this is enabled...
            ;; hopefully this doesn't cause problems
            (setq mode-require-final-newline nil))
  :init (progn
          (global-ethan-wspace-mode 1)
          ;; disable ethan-wspace caring about tabs in Makefile's
          (defun makefile-tabs-are-less-evil ()
            "Disable ethan-wspace from caring about tabs in Makefile's."
            (setq ethan-wspace-errors (remove 'tabs ethan-wspace-errors)))

          (add-hook 'makefile-mode-hook 'makefile-tabs-are-less-evil)))

(use-package evil
  :ensure t
  :init (evil-mode t)
  :config (progn
            ;; make cursor easier to see
            (setq evil-normal-state-cursor '("#b294bb" box))
            (setq evil-insert-state-cursor '("#de935f" bar))
            (setq evil-emacs-state-cursor '("#cc6666" box))

            (dolist (mode '(comint-mode
                            eshell-mode
                            inferior-emacs-lisp-mode
                            git-rebase-mode
                            gtags-select-mode
                            magit-branch-manager-mode
                            paradox-menu-mode
                            pylookup-mode
                            semantic-symref-results-mode
                            shell-mode
                            svn-status-mode
                            term-mode))
              (evil-set-initial-state mode 'emacs))

            ;; fixup company-complete-number to be handled better with evil
            (evil-declare-change-repeat 'company-complete-number)

            (defun apm-evil-jump-to-tag (orig-fun &rest args)
              "Make use of gtags / elisp-slime-nav for finding definitions.

If no gtags or elisp-slime-nav support then ORIG-FUN with ARGS
will be used instead."
              (cond
               ((bound-and-true-p gtags-mode)
                (gtags-find-tag-from-here))
               ((bound-and-true-p elisp-slime-nav-mode)
                (elisp-slime-nav-find-elisp-thing-at-point (thing-at-point 'symbol)))
               (t
                (apply orig-fun args))))

            (advice-add 'evil-jump-to-tag :around #'apm-evil-jump-to-tag)))

(use-package evil-args
  :ensure t
  :config (progn
            ;; bind evil-args text objects
            (define-key evil-inner-text-objects-map "a" 'evil-inner-arg)
            (define-key evil-outer-text-objects-map "a" 'evil-outer-arg)

            ;; bind evil-forward/backward-args
            (define-key evil-normal-state-map "L" 'evil-forward-arg)
            (define-key evil-normal-state-map "H" 'evil-backward-arg)
            (define-key evil-motion-state-map "L" 'evil-forward-arg)
            (define-key evil-motion-state-map "H" 'evil-backward-arg)

            ;; bind evil-jump-out-args
            (define-key evil-normal-state-map "K" 'evil-jump-out-args)))

(use-package evil-search-highlight-persist
  :ensure t
  :init (global-evil-search-highlight-persist t))

(use-package evil-jumper
  :ensure t)

(use-package evil-leader
  :ensure t
  :config (progn
            (setq evil-leader/leader ","
                  evil-leader/in-all-states t))
  :init (progn
          (global-evil-leader-mode 1)
          (evil-leader/set-key
            "ci" 'evil-surround-change
            "cc" 'evilnc-comment-or-uncomment-lines
            "fc" 'flycheck-buffer
            "fn" 'flycheck-next-error
            "fp" 'flycheck-previous-error
            "gt" 'gtags-find-tag
            "gr" 'gtags-find-rtag
            "gs" 'gtags-find-symbol
            "gc" 'auto-gtags-create-or-update
            "jw" 'evil-ace-jump-word-mode ; ,jw for Ace Jump (word)
            "jl" 'evil-ace-jump-line-mode ; ,jl for Ace Jump (line)
            "jc" 'evil-ace-jump-char-mode ; ,jc for Ace Jump (char)
            "ma" 'mc/mark-all-like-this-in-defun
            "mw" 'mc/mark-all-words-like-this-in-defun
            "ms" 'mc/mark-all-symbols-like-this-in-defun
            "md" 'mc/mark-all-like-this-dwim
            "rw" 'rotate-windows
            "zt" 'ace-jump-zap-to-char    ; ,zt for Ace Jump Zap To Char
            "zu" 'ace-jump-zap-up-to-char ; ,zu for Ace Jump Zap UP To Char
            "x" 'smex
            "SPC" 'evil-search-highlight-persist-remove-all)))

(use-package evil-nerd-commenter
  :ensure t)

(use-package evil-numbers
  :ensure t)

(use-package evil-space
  :ensure t
  :init (evil-space-default-setup))

(use-package evil-surround
  :ensure t
  :init (global-evil-surround-mode 1))

(use-package evil-visualstar
  :ensure t)

(use-package exec-path-from-shell
  :ensure t
  :init (when (memq window-system '(mac ns))
          (exec-path-from-shell-initialize)))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package files
  :bind ("C-c r" . revert-buffer))

(use-package flycheck
  :ensure t
  :diminish (flycheck-mode . (concat " " [#xF00C]))
  :config (setq flycheck-completion-system 'ido)
  :init (global-flycheck-mode +1))

(use-package flycheck-cohda-c-style
  :load-path "vendor/flycheck-cohda-c-style")

(use-package flycheck-pos-tip
  :ensure t
  :defer t
  :init (setq flycheck-display-errors-function #'flycheck-pos-tip-error-messages))

(use-package flyspell
  :diminish flyspell-mode)

(use-package fuzzy
  :ensure t)

(use-package git-commit-mode
  :ensure t)

(use-package gitconfig-mode
  :ensure t)

(use-package gitignore-mode
  :ensure t)

(use-package hungry-delete
  :ensure t
  :init (global-hungry-delete-mode))

(use-package ido
  :config (progn
            (setq ido-enable-flex-matching t
                  ;; use ido virtual buffers to remember previously opened files
                  ido-use-virtual-buffers t)
            ;; when using ido, the confirmation is rather annoying...
            (setq confirm-nonexistent-file-or-buffer nil)
            ;; disable ido faces to see flx highlights
            (setq ido-use-faces nil))
  :init (progn
          (ido-mode t)
          (ido-everywhere t)))

(use-package ido-ubiquitous
  :ensure t
  :init (ido-ubiquitous-mode t))

(use-package ido-vertical-mode
  :ensure t
  :init (ido-vertical-mode t))

(use-package imenu
  :bind ("C-x C-i" . imenu))

(use-package ispell
  :defer t
  :config (progn
            ;; use gb dictionary via aspell if available
            (when (executable-find "aspell")
              (setq ispell-program-name "aspell"
                    ispell-dictionary "british"
                    ispell-extra-args '("--sug-mode=ultra")))))

(use-package flx-ido
  :ensure t
  :init (flx-ido-mode t))

(use-package gdb-mi
  :config (progn
            ;; use gdb-many-windows by default
            (setq gdb-many-windows t)
            ;; Non-nil means display source file containing the main routine at startup
            (setq gdb-show-main t)))

(use-package gud
  :config (progn
            (defun apm-enable-gud-tooltip-mode ()
              "Enable `'gud-tooltip-mode'."
              ;; enable tooltips in gud mode buffer
              (gud-tooltip-mode t))

            (add-hook 'gud-mode-hook 'apm-enable-gud-tooltip-mode)))

;;; gtags
(use-package auto-gtags
  :load-path "lisp/"
  :config (progn
            (add-to-list 'auto-gtags-ignore-paths ".*/linux-3.0.35/")
            (add-to-list 'auto-gtags-ignore-paths ".*/linux-smx6_03/")
            (add-to-list 'auto-gtags-ignore-paths ".*/linux-imx/")
            (add-to-list 'auto-gtags-ignore-paths ".*/2.6.28/")
            ;; auto try and create / update gtags for c common modes
            (add-hook 'c-mode-common-hook #'auto-gtags-create-or-update)))

(use-package gtags
  ;; stop gtags.el stealing middle mouse click paste
  :config (progn
            (define-key gtags-mode-map [mouse-2] 'mouse-yank-primary)
            ;; enable gtags in all c common mode buffers
            (add-hook 'c-mode-common-hook #'gtags-mode))
  :diminish (gtags-mode . (concat " " [#xF02C])))

(use-package js2-mode
  :ensure t
  :init (progn
          (defun apm-js2-mode-setup ()
            "Setup js2-mode."
            (setq mode-name "js2"))

          (add-hook 'js2-mode-hook 'apm-js2-mode-setup)))

(use-package lisp-mode
  :config (progn
            (defun apm-emacs-lisp-mode-setup ()
              "Setup Emacs Lisp mode."
              (setq mode-name "el")
              ;; use aggressive indent
              (aggressive-indent-mode 1)
              (eldoc-mode t)
              ;; use smartparens in strict mode for lisp
              (smartparens-strict-mode +1))

            (add-hook 'emacs-lisp-mode-hook 'apm-emacs-lisp-mode-setup)))

(use-package magit
  :ensure t
  :defer t
  :bind ("C-x g" . magit-status)
  :diminish magit-auto-revert-mode
  :config (progn
            ;; full screen magit-status
            (defun apm-fullscreen-magit-status (orig-fun &rest args)
              "Create a fullscreen `magit-status' via ORIG-FUN and ARGS."
              (window-configuration-to-register :magit-fullscreen)
              (apply orig-fun args)
              (delete-other-windows))

            (advice-add 'magit-status :around #'apm-fullscreen-magit-status)

            (defun magit-quit-session ()
              "Restore the previous window config and kill the magit buffer."
              (interactive)
              (kill-buffer)
              (jump-to-register :magit-fullscreen))

            (define-key magit-status-mode-map (kbd "q") 'magit-quit-session)))

(use-package markdown-mode
  :ensure t
  :mode
  (("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :config (progn
            (unless (executable-find markdown-command)
              (apm-notify "markdown not found - is it installed?"))))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this))
  :config (setq mc/unsupported-minor-modes '(company-mode flyspell-mode))
  :init (eval-after-load 'evil
          '(progn
             (add-hook 'multiple-cursors-mode-enabled-hook 'evil-emacs-state)
             (add-hook 'multiple-cursors-mode-disabled-hook 'evil-normal-state))))

(use-package paradox
  :ensure t)

(use-package php-mode
  :ensure t)

(use-package powerline
  :ensure t
  :init (powerline-default-theme))

(use-package prog-mode
  :config (progn
            (defun apm-programming-setup ()
              "Tweaks and customisations for all programming modes."
              ;; highlight lines longer than 80 chars with column-enforce-mode
              (eval-after-load 'column-enforce-mode
                (column-enforce-mode))
              ;; turn on spell checking for strings and comments
              (flyspell-prog-mode)
              ;; highlight TODO and fixme so it looks scary
              (font-lock-add-keywords nil '(("\\<\\(TODO\\|todo\\|FIXME\\|fixme\\)" 1 font-lock-warning-face t))))

            (add-hook 'prog-mode-hook 'apm-programming-setup)))

(use-package projectile
  :ensure t
  :diminish (projectile-mode . (concat " " [#xF013]))
  :init (projectile-global-mode))

(use-package rainbow-mode
  :ensure t
  :init (dolist (hook '(css-mode-hook html-mode-hook))
          (add-hook hook 'rainbow-mode)))

;; save minibuffer history
(use-package savehist
  :init (savehist-mode 1))

(use-package saveplace
  :config (progn
            (setq-default save-place t)
            (setq save-place-file (expand-file-name ".places" user-emacs-directory))))

(use-package scratch
  :ensure t)

(use-package semantic
  :config (progn
            ;; parse include headers in idle time
            (setq semantic-idle-work-update-headers-flag t)

            ;; get semantic to index back to various top-level marker files
            (defvar apm-semantic-project-root-markers
              '(".git" "GTAGS" "TAGS" ".svn" "Makefile"))

            (setq semanticdb-project-root-functions
                  (mapcar #'(lambda (file)
                              (eval `(lambda (directory)
                                       (locate-dominating-file directory ,file))))
                          apm-semantic-project-root-markers)))
  :init (progn
          ;; semantic and semanticdb - stores semantic information in a db so is
          ;; faster to compute next time a file is loaded
          (semantic-mode 1)
          (global-semanticdb-minor-mode 1)

          ;; show summary of tag at point when idle
          (global-semantic-idle-summary-mode 1)))

(use-package smartparens
  :ensure t
  :diminish (smartparens-mode . " ()")
  :config (progn
            (require 'smartparens-config)
            (setq sp-base-key-bindings 'paredit)
            ;; always jump out of string when hitting end "
            (setq sp-autoskip-closing-pair 'always)
            (setq sp-hybrid-kill-entire-symbol nil)
            (sp-use-paredit-bindings)

            ;; highlights matching pairs
            (show-smartparens-global-mode +1)

            ;; disable pairing of ' in minibuffer
            (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)

            ;; use smartparens to automatically indent correctly when opening
            ;; a new block
            (defun apm-c-mode-common-open-block (&rest ignored)
              "Open a new brace or bracket expression, with relevant newlines and indent (IGNORED is ignored)."
              (newline)
              (indent-according-to-mode)
              (forward-line -1)
              (indent-according-to-mode))

            (dolist (mode '(c-mode c++-mode java-mode))
              (sp-local-pair mode "{" nil :post-handlers '((apm-c-mode-common-open-block "RET"))))))

(use-package smex
  :ensure t
  :bind (([remap execute-extended-command] . smex))
  :config (progn
            (setq smex-save-file (expand-file-name ".smex-items" user-emacs-directory))))

(use-package solarized-theme
  :ensure t
  :defer t
  :init (load-theme 'solarized-light t))

(use-package trac-wiki
  :load-path "vendor/"
  :config
  (setq trac-projects '(("mk2"
                         :endpoint "http://projects.cohda.wireless:8000/trac/mk2/login/xmlrpc"
                         :login "amurray"))))

(use-package unicode-fonts
  :ensure t
  :init (unicode-fonts-setup))

(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :init (progn
          (global-undo-tree-mode 1)))

(use-package uniquify
  :config (setq uniquify-buffer-name-style 'post-forward
                uniquify-separator ":"
                uniquify-after-kill-buffer-p t
                uniquify-ignore-buffers-re "^\\*"))

(use-package web-jump
  :bind ("C-x w" . webjump))

(use-package which-func
  :init (which-function-mode t))

(use-package whitespace
  :diminish whitespace-mode)

(use-package xml-rpc
  :ensure t)

(use-package yasnippet
  :ensure t
  :diminish (yas-minor-mode . (concat " " [#xF0C4]))
  :config (progn
            ;; set this first so we don't get the bundled snippets loaded since
            ;; they don't generally match my desired style / indentation etc
            (setq yas-snippet-dirs (expand-file-name "snippets" user-emacs-directory))
            ;; prompt using ido
            (setq yas-prompt-functions '(yas/ido-prompt yas/completing-prompt yas/no-prompt)))
  :init (yas-global-mode 1))

(provide 'init)

;;; init.el ends here
