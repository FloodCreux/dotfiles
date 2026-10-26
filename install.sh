#!/usr/bin/env bash
# ============================================
# DOTFILES BOOTSTRAP SCRIPT
# ============================================
# Bootstraps a fresh macOS system: Homebrew,
# Stow and mise, runs setup.sh, then installs
# Brewfile packages and mise tools.
# ============================================

set -euo pipefail

# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$DOTFILES_DIR"

if [ "$(uname -s)" != "Darwin" ]; then
    error "This bootstrap script only supports macOS."
    exit 1
fi

# ============================================
# HOMEBREW
# ============================================
header "Homebrew"

if command_exists brew; then
    success "$(brew --version | head -n 1)"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    command_exists brew || {
        error "Homebrew installation failed"
        exit 1
    }
    success "Homebrew installed"
fi

brew update

# ============================================
# GNU STOW
# ============================================
header "GNU Stow"

if command_exists stow; then
    success "$(stow --version | head -n 1)"
else
    brew install stow
fi

# ============================================
# MISE
# ============================================
header "mise"

if command_exists mise; then
    success "$(mise --version)"
else
    info "Installing mise..."
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
    command_exists mise || {
        error "mise installation failed"
        exit 1
    }
fi

# ============================================
# DOTFILES
# ============================================
# Runs before packages so the global mise config is linked for `mise install`.
header "Dotfiles"

bash "$DOTFILES_DIR/setup.sh"

# ============================================
# PACKAGES
# ============================================
header "Packages"

read -p "Install all Brewfile packages and mise tools? This can take a while. (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew bundle install --file "$DOTFILES_DIR/Brewfile" --verbose ||
        warn "Some Brewfile packages failed; retry with: mise run brew"
    mise trust "$DOTFILES_DIR/mise.toml"
    mise install ||
        warn "Some mise tools failed; retry with: mise install"
else
    warn "Skipped. Install later with: mise run brew && mise install"
fi

header "Bootstrap complete"
info "Run 'mise tasks' to see available commands."
warn "Aerospace and shell changes may need a logout or a new terminal."
