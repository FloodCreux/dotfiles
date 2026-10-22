;;; -*- lexical-binding: t -*-

(setq custom-file "~/.config/emacs/custom.el")

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; gruber-darker-theme lacks a lexical-binding cookie; load-theme evals it
;; from a temp buffer, which triggers a warning we can't fix upstream.
(require 'warnings)
(add-to-list 'warning-suppress-log-types '(files missing-lexbind-cookie eval-buffer))

(load custom-file 'noerror)

(add-to-list 'default-frame-alist `(font . "Iosevka Nerd Font Mono-14"))

(mapc 'load (file-expand-wildcards "~/.config/emacs/plugins/*.el"))

(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(ido-mode 1)
(ido-everywhere 1)
(global-display-line-numbers-mode)
