;; experiment: noramark mode

;;; Customizable Variables ====================================================

(defvar noramark-mode-hook nil
  "Hook run when entering NoraMark mode.")

(defgroup noramark nil
  "Major mode for editing text files in NoraMark format."
  :prefix "noramark-"
  :group 'noramark)



;;; Font Lock =================================================================

(require 'font-lock)

(defvar noramark-header-face 'noramark-header-face
  "Face name to use as a base for header.")

(defvar noramark-inline-code-face 'noramark-inline-code-face
  "Face name to use for inline code.")

(defvar noramark-list-face 'noramark-list-face
  "Face name to use for list markers.")

(defvar noramark-pre-face 'noramark-pre-face
  "Face name to use for preformatted text.")

(defvar noramark-language-keyword-face 'noramark-language-keyword-face
  "Face name to use for programming language identifiers.")

(defvar noramark-link-face 'noramark-link-face
  "Face name to use for links.")

(defvar noramark-keyword-face 'noramark-keyword-face
  "Face name to use for noramark keywords.")

(defvar noramark-frontmatter-face 'noramark-frontmatter-face
  "Face name to use for noramark frontmatter.")

(defvar noramark-command-face 'noramark-command-face
  "Face name to use for noramark command.")

(defgroup noramark-faces nil
  "Faces used in NoraMark Mode"
  :group 'noramark
  :group 'faces)

(defface noramark-header-face
  '((t (:inherit font-lock-function-name-face :weight bold)))
  "Base face for headers."
  :group 'noramark-faces)

(defface noramark-command-face
  '((t (:inherit font-lock-comment-face)))
  "command face."
  :group 'noramark-faces)

(defface noramark-inline-code-face
  '((t (:inherit font-lock-constant-face)))
  "Face for inline code."
  :group 'noramark-faces)

(defface noramark-list-face
  '((t (:inherit font-lock-string-face)))
  "Face for list item markers."
  :group 'noramark-faces)

(defface noramark-pre-face
  '((t (:inherit font-lock-constant-face)))
  "Face for preformatted text."
  :group 'noramark-faces)

(defface noramark-language-keyword-face
  '((t (:inherit font-lock-type-face)))
  "Face for programming language identifiers."
  :group 'noramark-faces)

(defface noramark-link-face
  '((t (:inherit font-lock-keyword-face)))
  "Face for links."
  :group 'noramark-faces)

(defface noramark-keyword-face
  '((t (:inherit font-lock-keyword-face)))
  "Face for keyword."
  :group 'noramark-faces)

(defface noramark-frontmatter-face
  '((t (:inherit font-lock-comment-face)))
  "Face for frontmatter."
  :group 'noramark-faces)

(defconst noramark-regex-command-param
  "\\(\\#[[:alpha:][:digit:]-_]+\\)?\\(\\.[[:alpha:][:digit:]-_]+\\)?\\(.*?)\\)?\\(\\[.*\\]\\)?"
  "Regular expression for a #id.class(parameter)[namedparameter]
Group 1 matchs the id.
Group 2 matchs the class
Group 3 matches the parameter.
Group 4 matches the named parameter.")

(defconst noramark-regex-pre-head
  (concat "^[[:space:]]*\\(pre\\|code\\)" noramark-regex-command-param "[[:space:]]*\\({\\)[[:space:]]*?\n"))

(defconst noramark-regex-pre-tail
  "^[[:space:]]*\\(}\\)[[:space:]]*$")

(defconst noramark-regex-header
  "^[ \t]*[\#]+.*$"
  "Regexp identifying NoraMark headers.")

(defconst noramark-frontmatter
  "^\\(---\\)\\(\\(\n[^\n]*\\)*?\\)\n\\(---\\)"
  "Regular expression for frontmatter;")

(defvar noramark-mode-font-lock-keywords-basic
  (list
   ; frontmatter
   '("^\\(---\\)\\(\\(\n[^\n]*\\)*?\\)\n\\(---\\)"
     (1 'font-lock-keyword-face)
     (2 'font-lock-comment-face)
     (4 'font-lock-keyword-face))
   (cons 'noramark-match-pre-command-complex
         '((1 'noramark-command-face nil t) ; cmd
           (2 'font-lock-keyword-face nil t) ; id
           (3 'font-lock-keyword-face nil t) ; class
           (4 'font-lock-string-face nil t) ; param
           (5 'font-lock-string-face nil t) ; named param
           (6 'noramark-command-face nil t) ; open 
           (7 'font-lock-keyword-face nil t) ; language
           (8 'noramark-pre-face nil t) ; body of pre
           (9 'noramark-command-face nil t))) ; close
   (cons 'noramark-match-pre-command
         '((1 'noramark-command-face nil t) ; cmd
           (2 'font-lock-keyword-face nil t) ;id 
           (3 'font-lock-keyword-face nil t) ;class
           (4 'font-lock-string-face nil t)  ;param
           (5 'font-lock-string-face nil t)  ;named param
           (6 'noramark-command-face nil t) ; open
           (7 'noramark-pre-face nil t) ; body
           (8 'noramark-command-face nil t))) ;close
   ; block-end
   '("^[ \t]*}[ \t]*\n" . noramark-command-face)
   ; comment
   '("^[ \t]*//.*$" . font-lock-comment-face)
   ; ul
   '("^[ \t]*[*]+" . noramark-list-face)
   ; ol
   '("^[ \t]*[[:digit:]]+\\.[ \t]" . noramark-list-face)
   ; headings
   '("^[ \t]*[\#]+.*$" . noramark-header-face)
   ; headings: hN
   '("^[ \t]*h[1-6]:.*$" . noramark-header-face)

   ; definition-list short
   (cons 'noramark-match-definition-list-short
         '((1 'noramark-command-face)
           (2 'noramark-command-face)))
   ; definition-list long
   (cons 'noramark-match-definition-list-long
         '((1 'noramark-command-face)
           (2 'noramark-command-face)))

   (cons 'noramark-match-line-command
         '((1 'noramark-command-face)
           (2 'font-lock-keyword-face nil t)
           (3 'font-lock-keyword-face nil t)
           (4 'font-lock-string-face nil t)
           (5 'font-lock-string-face nil t)
           (6 'noramark-command-face)))
   (cons 'noramark-match-inline-command
         '((1 'noramark-command-face)
           (2 'font-lock-keyword-face nil t)
           (3 'font-lock-keyword-face nil t)
           (4 'font-lock-string-face nil t)
           (5 'font-lock-string-face nil t)
           (6 'noramark-command-face nil t)
           (7 'noramark-command-face))))
  "Syntax highlighting for NoraMark files.")


;;; Noramark Font Lock Matching Functions =====================================
(defun noramark-match-line-command (last)
  (let (cmd id class param nparam comma)
    (cond ((search-forward-regexp (concat "^[[:space:]]*\\([A-Za-z0-9-_]+\\)" noramark-regex-command-param "[[:space:]]*\\([:{]\\)") last t)
           (beginning-of-line)
           (setq cmd (list (match-beginning 1) (match-end 1))
                 id (list (match-beginning 2) (match-end 2))
                 class (list (match-beginning 3) (match-end 3))
                 param (list (match-beginning 4) (match-end 4))
                 nparam (list (match-beginning 5) (match-end 5))
                 comma (list (match-beginning 6) (match-end 6))
                 all (list (match-beginning 0) (match-end 0)))
           (forward-line)
           (set-match-data (append all cmd id class param nparam comma))
           t)
          (t nil))))

(defun noramark-match-definition-list-short (last)
  (let (all open delimiter) 
    (cond ((search-forward-regexp "^[ \t]*\\(;:\\)[^:]*?\\(:\\)[[:space:]]" last t)
           (beginning-of-line)
           (setq open (list (match-beginning 1) (match-end 1))
                 delimiter (list (match-beginning 2) (match-end 2))
                 all (list (match-beginning 0) (match-end 0)))
           (forward-line)
           (set-match-data (append all open delimiter))
           t)
          (t nil))))

(defun noramark-match-definition-list-long (last)
  (let (all open delimiter) 
    (cond ((search-forward-regexp "^[ \t]*\\(;:\\)[^{]*?\\({\\)[[:space:]]*?\n" last t)
           (beginning-of-line)
           (setq open (list (match-beginning 1) (match-end 1))
                 delimiter (list (match-beginning 2) (match-end 2))
                 all (list (match-beginning 0) (match-end 0)))
           (forward-line)
           (set-match-data (append all open delimiter))
           t)
          (t nil))))
                 


(defun noramark-match-inline-command (last)
  (let (cmd id class param nparam open close)
    (cond ((search-forward-regexp (concat "\\(\\[[A-Za-z0-9-_]+\\)" noramark-regex-command-param "\\({\\).*?\\(}]\\)") last t)
           (beginning-of-line)
           (setq cmd (list (match-beginning 1) (match-end 1))
                 id (list (match-beginning 2) (match-end 2))
                 class (list (match-beginning 3) (match-end 3))
                 param (list (match-beginning 4) (match-end 4))
                 nparam (list (match-beginning 5) (match-end 5))
                 open (list (match-beginning 6) (match-end 6))
                 close (list (match-beginning 7) (match-end 7))
                 all (list (match-beginning 0) (match-end 0)))
           (goto-char (1+ (match-end 0)))
           (set-match-data (append all cmd id class param nparam open close))
           t)
          (t nil))))

(defun noramark-match-pre-command (last)
  "Match Noramark pre command from point to LAST."
  (let (cmd id class param nparam open cm lang body close all)
    (cond ((search-forward-regexp
            noramark-regex-pre-head last t)
           (beginning-of-line)
           (setq cmd (list (match-beginning 1) (match-end 1))
                 id (list (match-beginning 2) (match-end 2))
                 class (list (match-beginning 3) (match-end 3))
                 param (list (match-beginning 4) (match-end 4))
                 nparam (list (match-beginning 5) (match-end 5))
                 open (list (match-beginning 6) (match-end 6)))
           (setq body (list (point)))
           (cond ((search-forward-regexp noramark-regex-pre-tail last t)
                  (forward-line)
                  (setq body (reverse (cons (1- (match-beginning 0)) body))
                        close (list (match-beginning 0) (match-end 0))
                        all (list (car cmd) (match-end 0)))
                  (set-match-data (append all cmd id class param nparam open body close))

                  t)
                 (t nil))
           t)
          (t nil))))

(defun noramark-match-pre-command-complex (last)
  "Match Noramark pre command from point to LAST."
  (let (cmd id class param nparam open lang body close all)
    (cond ((search-forward-regexp
            (concat "^[[:space:]]*\\(pre\\|code\\)" noramark-regex-command-param "[[:space:]]*\\({//\\)\\([A-Za-z-_]*?\\)?[[:space:]]*?\n") last t)
           (beginning-of-line)
           (setq cmd (list (match-beginning 1) (match-end 1))
                 id (list (match-beginning 2) (match-end 2))
                 class (list (match-beginning 3) (match-end 3))
                 param (list (match-beginning 4) (match-end 4))
                 nparam (list (match-beginning 5) (match-end 5))
                 open (list (match-beginning 6) (match-end 6))
                 lang (list (match-beginning 7) (match-end 7)))
           (setq body (list (point)))
           (cond ((search-forward-regexp (concat "^[[:space:]]*\\(//}\\)[[:space:]]*$") last t)
                  (forward-line)
                  (setq body (reverse (cons (1- (match-beginning 0)) body))
                        close (list (match-beginning 0) (match-end 0))
                        all (list (car cmd) (match-end 0)))
                  (set-match-data (append all cmd id class param nparam open lang body close))

                  t)
                 (t nil))
           t)
          (t nil))))



(defun noramark-reload-extensions ()
  "Check settings, update font-lock keywords, and re-fontify buffer."
  (interactive)
  (when (eq major-mode 'noramark-mode)
    (setq noramark-mode-font-lock-keywords
          noramark-mode-font-lock-keywords-basic)
    (setq font-lock-defaults '(noramark-mode-font-lock-keywords))
    (font-lock-refresh-defaults)))

(defun noramark-font-lock-extend-region-pre ()
  (eval-when-compile (defvar font-lock-beg) (defvar font-lock-end))
  (save-excursion
    (goto-char font-lock-beg)
    (let ((found (or (re-search-backward noramark-regex-pre-head nil t) (point-min))))
      (goto-char font-lock-end)
      (when (re-search-forward noramark-regex-pre-tail nil t)
        (setq font-lock-end (match-beginning 0))
        (setq font-lock-beg found)))))

;;; Syntax Table ==============================================================

(defvar noramark-mode-syntax-table
  (make-syntax-table text-mode-syntax-table)
  "Syntax table for `noramark-mode'.")

;;; Mode Definition  ==========================================================

;;;###autoload
(define-derived-mode noramark-mode text-mode "NoraMark"
  "Major mode for editing NoraMark files."
  ;; Font lock.
  (set (make-local-variable 'noramark-mode-font-lock-keywords) nil)
  (set (make-local-variable 'font-lock-multiline) t)
  (noramark-reload-extensions)
  (add-hook 'font-lock-extend-region-functions
            'noramark-font-lock-extend-region-pre))


;;;###autoload(add-to-list 'auto-mode-alist '("\\.nora\\'" . noramark-mode))



(provide 'noramark-mode)

;;; noramark-mode.el ends here


