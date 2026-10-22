;;; -*- lexical-binding: t -*-

;; Download Magit
(unless (package-installed-p 'magit)
  (package-install 'magit))

(require 'magit)

