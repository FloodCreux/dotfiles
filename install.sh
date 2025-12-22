#!/usr/bin/env bash
# ============================================
# DOTFILES BOOTSTRAP SCRIPT
# ============================================
# This script bootstraps a fresh macOS system
# by installing Homebrew, required tools, and
# setting up dotfiles automatically.
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

header() {
    echo ""
    echo -e "${MAGENTA}========================================${NC}"
    echo -e "${MAGENTA}$1${NC}"
    echo -e "${MAGENTA}========================================${NC}"
    echo ""
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================
# OS DETECTION
# ============================================
header "Detecting Operating System"

OS="$(uname -s)"
case "$OS" in
    Darwin)
        info "Operating System: macOS"
        OS_TYPE="macos"
        ;;
    Linux)
        info "Operating System: Linux"
        OS_TYPE="linux"
        warn "This script is primarily designed for macOS. Some features may not work."
        ;;
    *)
        error "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# ============================================
# HOMEBREW INSTALLATION
# ============================================
header "Installing Homebrew"

if command_exists brew; then
    success "Homebrew is already installed"
    BREW_VERSION=$(brew --version | head -n 1)
    info "$BREW_VERSION"
else
    info "Installing Homebrew..."

    if [ "$OS_TYPE" = "macos" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        error "Homebrew installation on Linux is not automated by this script."
        info "Please visit: https://brew.sh for installation instructions"
        exit 1
    fi

    # Add Homebrew to PATH for current session
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if command_exists brew; then
        success "Homebrew installed successfully"
    else
        error "Homebrew installation failed"
        exit 1
    fi
fi

# Update Homebrew
info "Updating Homebrew..."
brew update

# ============================================
# INSTALL GNU STOW
# ============================================
header "Installing GNU Stow"

if command_exists stow; then
    success "GNU Stow is already installed"
    STOW_VERSION=$(stow --version | head -n 1)
    info "$STOW_VERSION"
else
    info "Installing GNU Stow via Homebrew..."
    brew install stow

    if command_exists stow; then
        success "GNU Stow installed successfully"
    else
        error "GNU Stow installation failed"
        exit 1
    fi
fi

# ============================================
# INSTALL BREW PACKAGES
# ============================================
header "Installing Homebrew Packages"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

if [ -f "$BREWFILE" ]; then
    info "Found Brewfile at: $BREWFILE"

    # Ask user if they want to install all packages
    echo ""
    warn "This will install ~100 packages including:"
    echo "  - Development tools (docker, kubernetes, python, rust, etc.)"
    echo "  - CLI utilities (fzf, eza, zoxide, tmux, etc.)"
    echo "  - macOS apps (Aerospace, Ghostty, Raycast, etc.)"
    echo ""
    read -p "Do you want to install all Brewfile packages? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Installing packages from Brewfile..."
        info "This may take 10-30 minutes depending on your system..."

        cd "$DOTFILES_DIR"
        if brew bundle --verbose; then
            success "All Brewfile packages installed successfully"
        else
            error "Some packages failed to install"
            warn "You can run 'brew bundle' manually later to retry"
        fi
    else
        warn "Skipped Brewfile package installation"
        info "You can install them later with: make brew"
    fi
else
    warn "Brewfile not found at: $BREWFILE"
    info "Skipping package installation"
fi

# ============================================
# SETUP DOTFILES
# ============================================
header "Setting Up Dotfiles"

SETUP_SCRIPT="$DOTFILES_DIR/setup.sh"

if [ -f "$SETUP_SCRIPT" ]; then
    info "Running setup script..."

    # Make setup script executable
    chmod +x "$SETUP_SCRIPT"

    # Run the setup script
    if bash "$SETUP_SCRIPT"; then
        success "Dotfiles setup completed successfully"
    else
        error "Dotfiles setup failed"
        exit 1
    fi
else
    error "Setup script not found at: $SETUP_SCRIPT"
    exit 1
fi

# ============================================
# POST-INSTALLATION
# ============================================
header "Installation Complete!"

echo ""
success "Your dotfiles have been successfully installed!"
echo ""

info "Next steps:"
echo "  1. Restart your terminal or run: exec \$SHELL"
echo "  2. Configure git identities:"
echo "     - Edit ~/.config/git/.gitconfig-personal"
echo "     - Edit ~/.config/git/.gitconfig-work"
echo "  3. Add your SSH keys to ~/.ssh/"
echo "  4. (Optional) Import GPG keys for commit signing"
echo "  5. (Optional) Set up nix-darwin if using Nix"
echo ""

info "Useful commands:"
echo "  make help      - Show all available make targets"
echo "  make update    - Update dotfiles from git"
echo "  make brew      - Install/update Brewfile packages"
echo "  make uninstall - Remove all dotfile symlinks"
echo ""

warn "Some applications may require a logout/login or restart to take effect:"
echo "  - Aerospace (window manager)"
echo "  - SketchyBar (status bar)"
echo "  - Shell configurations (zsh/bash/nushell)"
echo ""
