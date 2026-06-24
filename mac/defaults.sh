#!/usr/bin/env bash

set -euo pipefail

[[ "$(uname)" == "Darwin" ]] || { echo "Not macOS, skipping."; exit 0; }

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock minimize-to-application -bool true

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true
defaults write com.apple.finder ShowPathBar -bool true
defaults write com.apple.finder ShowStatusBar -bool true


# Reload
killall Dock Finder SystemUIServer || true
