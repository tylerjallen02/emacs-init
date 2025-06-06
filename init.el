(setq gc-cons-threshold (* 100 1000 1000))

(require 'package)

(add-to-list 'load-path (expand-file-name "~/.emacs.d/babel"))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-verbose t)

(setq inhibit-startup-message t)

(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                treemacs-mode-hook
                shell-mode-hook
                eshell-mode-hook
                cider-repl-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package good-scroll
  :config
  (good-scroll-mode 1))

(defvar tyler/default-font-size 120)
(set-face-attribute 'default nil :font "DejaVuSansMono" :height 108)
(set-face-attribute 'fixed-pitch nil :font "DejaVuSansMono" :height 108)
(set-face-attribute 'variable-pitch nil :font "DejaVuSans" :height 108 :weight 'regular)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(use-package general
  :after evil
  :config
  (general-create-definer tyler/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (tyler/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "f" '(:ignore f :which-key "file")
    "fe" '(lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/Emacs.org")))
    "ff" 'find-file
    "i" '(:ignore i :which-key "insert")
    "ic" 'insert-char
    "v" 'vterm 
    "c" 'org-capture))


(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (unless evil-mode ;fix issue where it doesn't like initializing this when already using evil mode
    (evil-mode 1))
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual ine motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package doom-themes
 :config
 (load-theme 'doom-lantern t))
(use-package jetbrains-darcula-theme)
  ;; :config
  ;; (load-theme 'jetbrains-darcula))

(use-package doom-modeline
  :ensure t
  :init (setq doom-modeline-mode 1)
  :hook (window-setup . doom-modeline-mode)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  (ivy-prescient-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(tyler/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))



(defun efs/org-font-setup ()
   (set-face-attribute 'org-hide nil :inherit 'fixed-pitch) ;fix alignment of bullets
   ;; Replace list hyphen with dot
   (font-lock-add-keywords 'org-mode
                           '(("^ *\\([-]\\) "
                              (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

   ;; Set faces for heading levels
   (dolist (face '((org-level-1 . 1.2)
                   (org-level-2 . 1.05)
                   (org-level-3 . 1.05)
                   (org-level-4 . 1.0)
                   (org-level-5 . 1.1)
                   (org-level-6 . 1.1)
                   (org-level-7 . 1.1)
                   (org-level-8 . 1.1)))
     (set-face-attribute (car face) nil :font "DejaVuSans" :weight 'regular :height (cdr face)))
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  ;; (setq org-indent-indentation-per-level 3)
  (visual-line-mode 1))

(use-package org
  :hook (org-mode . efs/org-mode-setup)
  :init
  (setq org-startup-with-latex-preview t)
  :commands (org-capture org-agenda)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t)

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 0.9))
  (setq org-agenda-files
        '("~/.emacs.d/OrgFiles/Tasks.org"))
  (efs/org-font-setup)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "Next(n)" "|" "Done(d!)"))))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 200
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (kotlin . t)))

(setq org-confirm-babel-evaluate nil)
(setq org-babel-python-command "python3")

(with-eval-after-load 'org
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("ko" . "src kotlin"))
  (add-to-list 'org-structure-template-alist '("js" . "src javascript")))

(defun efs/org-babel-tangle-config()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/Emacs.org"))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

  (add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

(setq org-capture-templates
      '(("j" "Journal" plain (file+datetree "~/journal.org")
	 "%?")))

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(defun efs/lsp-mode-setup()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-l")
  :config
  (lsp-enable-which-key-integration t)
  (setq lsp-semantic-tokens-enable t))

;; (use-package flycheck
;;   :after lsp-mode 
;;   :init ())

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))
(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package clojure-mode
  :mode "\\.clj\\'"
  :hook (clojure-mode . lsp-deferred))

(use-package paredit
  :after clojure-mode
  :hook (clojure-mode . enable-paredit-mode))

(use-package cider
  :after clojure-mode
  :commands cider-jack-in)

(use-package tex
  :hook
  (LaTeX-mode . lsp-deferred)
  (LaTeX-mode . xenops-mode)
  :ensure auctex)
(use-package lsp-latex
  :after tex
  :init
  (setq lsp-latex-chktex-on-edit t))

(use-package xenops
  :after tex
  :init (setq xenops-reveal-on-entry t))

(use-package lsp-haskell
  :after haskell-mode)
(use-package haskell-mode
  :mode "\\.hs\\'"
  :hook (haskell-mode . lsp-deferred))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred))

(use-package lsp-pyright
  :after python-mode)

(use-package pyvenv
  :ensure t
  :defer t
  :diminish
  :config
  
  (setenv "WORKON_HOME" "~/pyenv/")
					; Show python venv name in modeline
  (setq pyvenv-mode-line-indicator '(pyvenv-virtual-env-name ("[venv:" pyvenv-virtual-env-name "] ")))
  (pyvenv-mode t))

(use-package js
  :hook (js-mode . lsp-deferred)
  (js-mode . smartparens-mode))

(use-package company
  ;; :config (add-to-list 'company-backends 'company-yasnippet)
  ;; :after lsp-mode
  :config (yas-global-mode 1)
  :hook (lsp-mode . company-mode)
  
  :bind
  (:map company-active-map
        ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 3)
  (company-idle-delay 0.25))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
   :diminish projectile-mode
   :config (projectile-mode)
   :custom((projectile-completion-system 'ivy))
   :bind-keymap
   ("C-c p" . projectile-command-map)
   :init
   (setq projectile-swtch-project-action #'projectile-dired)) 
 (use-package counsel-projectile
   :after projectile 
   :config (counsel-projectile-mode))

(tyler/leader-keys
  "p" '(:ignore p :which-key "projectile")
  "pf" 'projectile-find-file
  "pk" 'projectile-kill-buffers)

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package term
   :commands term
   :config (setq explicit-shell-file-name "bash")
   (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

 (use-package eterm-256color
   :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrolback 10000))

(defun efs/configure-eshell ()
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size 10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoreups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config
  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))
  
  (eshell-git-prompt-use-theme 'powerline))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (setq dired-kill-when-opening-new-dired-buffer t) ;Only keep one dired open, keep buffers from getting cluttered.
  (setq delete-by-moving-to-trash t)
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))


(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                  ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(setq gc-cons-threshold (* 4 1000 1000))

(use-package exec-path-from-shell
  :ensure t
  :config
  (setq exec-path-from-shell-variables '("OPENAI_API_KEY"))
  (exec-path-from-shell-initialize))

(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))
