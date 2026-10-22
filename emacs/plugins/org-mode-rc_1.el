;;; -*- lexical-binding: t -*-

;; Org mode
(global-set-key (kbd "C-x a") 'org-agenda)
(global-set-key (kbd "C-c C-x j") #'org-clock-jump-to-current-clock)

(setq org-agenda-files (list "~/Documents/Agenda"))

(setq org-export-backends '(md))
