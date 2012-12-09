;;; init-emacs-lisp.el --- Initialise emacs-lisp

;;; Commentary:
;; 

;;; Code:

(defun emacs-lisp-mode-setup ()
  "Setup Emacs Lisp mode."
  (setq mode-name "el")
  (turn-on-eldoc-mode))

(add-hook 'emacs-lisp-mode-hook 'emacs-lisp-mode-setup)

(provide 'init-emacs-lisp)

;;; init-emacs-lisp.el ends here
