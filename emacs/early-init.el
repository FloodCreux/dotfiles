;;; early-init.el -*- lexical-binding: t -*-

(when (and (eq system-type 'darwin) (native-comp-available-p))
  (setq native-comp-driver-options '("-mmacosx-version-min=26.0")))
