;;; emacs configuration file

;;; Personal Information
(setq user-full-name "Chao Liu")
(setq user-mail-address "chao.liu0307@gmail.com")

(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(package-initialize)

(global-linum-mode t);show line number
(set scroll-bar-mode 0);disable scroll bar
(global-auto-revert-mode);auto update the current file


;;;show the match of the brackets
(show-paren-mode t)


;;;Time Configuration
(display-time-mode 1);show time on the bar of the nimibuffer
(setq display-time-12hr-format t);12 hour format
(setq display-time-day-and-date t);time + date

;;;cursor stop blinking 
(blink-cursor-mode -1)
(transient-mark-mode 1)

;;;highlight the current row
(require 'hl-line)
(global-hl-line-mode t)


;;;M-k to kill the buffer and delete the window
(global-set-key [(meta k)] (lambda () 
                             (interactive) 
                             (kill-buffer) 
                             (delete-window))) 

;;;highlight the grammer
(global-font-lock-mode t)
(put 'set-goal-column 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'ipcase-region 'disabled nil)
(put 'Latex-hide-environment 'disabled nil)

(load-theme 'monokai t);load monokai theme

(require 'magit);load magit to do git control

;;;git-emacs
(add-to-list 'load-path "/Users/ChaoLiu/git-emacs/")
(require 'git-emacs)

;;;Arduino-mode
(setq auto-mode-alist (cons '("\\.\\(pde\\|ino\\)$" . arduino-mode) auto-mode-alist))
(autoload 'arduino-mode "arduino-mode" "Arduino editing mode." t)


;;;yasnippet mode 
(yas-global-mode 1)

;;;auto-complete mode
(require 'auto-complete)
(require 'auto-complete-config)
(global-auto-complete-mode t) 

;;; smex 
(require 'smex); Not needed if you use package.el
(smex-initialize) ; Can be omitted. This might cause a (minimal) delay 
                  ; when Smex is auto-initialized on its first run.
;;; ido mode
(require 'ido)
(ido-mode t)

;;;for Chinese environment
(set-language-environment 'Chinese-GB)
;;(set-keyboard-coding-system 'chinese-iso-8bit-dos)
(set-keyboard-coding-system 'euc-cn)
(set-clipboard-coding-system 'euc-cn)
(set-terminal-coding-system 'euc-cn)
(set-buffer-file-coding-system 'euc-cn)
(set-selection-coding-system 'euc-cn)
(modify-coding-system-alist 'process "*" 'euc-cn)
(setq default-process-coding-system
'(euc-cn . euc-cn))
(setq-default pathname-coding-system 'euc-cn)

;;;eshell configuration
(add-hook 'eshell-mode-hook (lambda()
           (outline-minor-mode 1)
           (setq outline-regexp "^[^#$\n]* [#>]+ "
                 scroll-margin 0
                 eshell-scroll-to-bottom-on-output t
                 eshell-scroll-show-maximum-output t)
           (add-to-list 'eshell-output-filter-functions 
                        'eshell-postoutput-scroll-to-bottom)
))

(add-hook 'eshell-load-hook
          (lambda()(setq last-command-start-time (time-to-seconds))))
(add-hook 'eshell-pre-command-hook
          (lambda()(setq last-command-start-time (time-to-seconds))))
(add-hook 'eshell-before-prompt-hook
          (lambda()
              (message "spend %g seconds"
                       (- (time-to-seconds) last-command-start-time))))

(defalias 'ff 'find-file)
(defalias 'ee (lambda()(find-file (expand-file-name "44eshell.el" init-dir))))
(defalias 'aa (lambda()(find-file eshell-aliases-file)))
(defalias 'rr (lambda()(find-file (expand-file-name "qref.org" sand-box))))
(defalias 'ss  'shell-command-to-string)

(defvar ac-source-eshell-pcomplete
  '((candidates . (pcomplete-completions))))
(defun ac-complete-eshell-pcomplete ()
  (interactive)
  (auto-complete '(ac-source-eshell-pcomplete)))
;; 自动开启 ac-mode
;; 需要 (global-auto-complete-mode 1)
(add-to-list 'ac-modes 'eshell-mode)
(setq ac-sources '(ac-source-eshell-pcomplete
                   ;; ac-source-files-in-current-dir
                   ;; ac-source-filename
                   ;; ac-source-abbrev
                   ;; ac-source-words-in-buffer
                   ;; ac-source-imenu
))
;;configure eshell prompt
(setq eshell-prompt-function
      '(lambda ()
         (concat
          user-login-name "@" system-name " "
          (if (search (directory-file-name (expand-file-name (getenv "HOME"))) (eshell/pwd))
              (replace-regexp-in-string (expand-file-name (getenv "HOME")) "~" (eshell/pwd))
            (eshell/pwd))
          (if (= (user-uid) 0) " # " " $ "))))
;;make the prompt of eshell colorful
(defun colorfy-eshell-prompt ()
  "Colorfy eshell prompt according to `user@hostname' regexp."
  (let* ((mpoint)
         (user-string-regexp (concat "^" user-login-name "@" system-name)))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward (concat user-string-regexp ".*[$#]") (point-max) t)
        (setq mpoint (point))
        (overlay-put (make-overlay (point-at-bol) mpoint) 'face '(:foreground "dodger blue")))
      (goto-char (point-min))
      (while (re-search-forward user-string-regexp (point-max) t)
        (setq mpoint (point))
        (overlay-put (make-overlay (point-at-bol) mpoint) 'face '(:foreground "green3"))
        ))))
(add-hook 'eshell-output-filter-functions 'colorfy-eshell-prompt)

(make-variable-buffer-local 'wcy-shell-mode-directory-changed)
(setq wcy-shell-mode-directory-changed t)
;; other configuration about eshell
(defun wcy-shell-mode-auto-rename-buffer-output-filter (text)
  (if (and (eq major-mode 'shell-mode)
           wcy-shell-mode-directory-changed)
      (progn
        (let ((bn  (concat "sh:" default-directory)))
          (if (not (string= (buffer-name) bn))
              (rename-buffer bn t)))
        (setq wcy-shell-mode-directory-changed nil))))
(defun wcy-shell-mode-auto-rename-buffer-input-filter (text)
  (if (eq major-mode 'shell-mode)
      (if ( string-match "^[ \t]*cd *" text)
          (setq wcy-shell-mode-directory-changed t))))
(add-hook 'comint-output-filter-functions 'wcy-shell-mode-auto-rename-buffer-output-filter)
(add-hook 'comint-input-filter-functions 'wcy-shell-mode-auto-rename-buffer-input-filter )

;;;google-c-style configuration
(add-to-list 'load-path (expand-file-name "~/.emacs.d"))
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;;;cc-mode configuration
(defun my-c-mode-hook ()
  (setq c-basic-offset 4
        indent-tabs-mode t
        default-tab-width 4))
(add-hook 'c-mode-hook 'my-c-mode-hook)

;;; Python mode
(setq auto-mode-alist
(cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist
(cons '("python" . python-mode)
interpreter-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)
;;;add these lines if you like color-based syntax highlighting
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

;;;Setting up matlab-mode
(add-to-list 'load-path "~/.emacs.d/matlab-emacs")
(load-library "matlab-load")
(matlab-cedet-setup)
;(custom-set-variables
; '(matlab-shell-command-switches '("-nodesktop -nosplash")))
;(add-hook 'matlab-mode-hook 'auto-complete-mode)
;(setq auto-mode-alist
;    (cons
;     '("\\.m$" . matlab-mode)
;     auto-mode-alist))

;;;emacs + auctex configuration for mac
;;;
(setenv "PATH" (concat "/usr/texbin:/usr/local/bin:" (getenv "PATH"))) 
(setq exec-path (append '("/usr/texbin" "/usr/local/bin") exec-path)) 

;(if (string-equal system-type "windows-nt")
;     (require 'tex-mik))
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(setq TeX-output-view-style (quote (("^pdf$" "." "evince %o %(outpage)"))))

(add-hook 'LaTeX-mode-hook
	  (lambda()
	    (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex%(mode)%' %t" TeX-run-TeX nil t))
	    (setq TeX-command-default "XeLaTeX")))

(mapc (lambda (mode)
      (add-hook 'LaTeX-mode-hook mode))
      (list 'auto-fill-mode
	    'LaTeX-math-mode
	    'turn-on-reftex
	    'linum-mode))
(add-hook 'LaTeX-mode-hook
          (lambda ()
           (setq TeX-auto-untabify t ; remove all tabs before saving
                  TeX-engine 'xetex ; ('xetex) | ('default)
                  TeX-show-compilation t) ; display compilation windows
            (TeX-global-PDF-mode t) ; PDF mode enable, not plain
            (setq TeX-save-query nil)
            (imenu-add-menubar-index)
	    ;(define-key LaTeX-mode-map (kbd "TAB") 'TeX-complete-symbol)
            ))
(setq TeX-view-program-list
      '(("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline %n %o %b")("Preview" "open -a Preview.app %o")))
(setq TeX-view-program-selection
      '((output-pdf "Skim")
        (output-dvi "xdvi")))
(setq TeX-insert-quote t)
(ispell-change-dictionary "american" t)
(setq-default ispell-program-name "aspell")
(add-hook 'LaTeX-mode-hook 'flyspell-mode)

(add-hook 'doc-view-mode-hook 'auto-revert-mode)
;end emacs + auctex
