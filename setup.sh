#!/usr/bin/env bash
# ============================================
# DOTFILES INSTALLATION SCRIPT
# ============================================
# This script uses GNU Stow to symlink dotfiles
# to ~/.config and creates necessary home directory
# symlinks for compatibility.
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================
# DEPENDENCY CHECKS
# ============================================
info "Checking dependencies..."

if ! command_exists stow; then
    error "GNU Stow is not installed!"
    info "Install with: brew install stow"
    exit 1
fi

success "All required dependencies found"

# ============================================
# BACKUP EXISTING CONFIGS
# ============================================
info "Backing up existing configurations..."

BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Files/directories to check for backup
BACKUP_TARGETS=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/.ssh/config"
    "$HOME/.config/nvim"
    "$HOME/.config/tmux"
    "$HOME/.config/zsh"
    "$HOME/.config/bash"
    "$HOME/.config/git"
    "$HOME/.config/starship"
)

BACKED_UP=0
for target in "${BACKUP_TARGETS[@]}"; do
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        info "Backing up: $target"
        mkdir -p "$BACKUP_DIR/$(dirname "$target")"
        cp -r "$target" "$BACKUP_DIR/$target"
        BACKED_UP=$((BACKED_UP + 1))
    fi
done

if [ $BACKED_UP -gt 0 ]; then
    success "Backed up $BACKED_UP items to: $BACKUP_DIR"
else
    info "No existing configs found to backup"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

# ============================================
# STOW PACKAGES
# ============================================
info "Installing dotfiles with GNU Stow..."

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Array of packages to stow
PACKAGES=(
    "aerospace"
    "bash"
    "direnv"
    "ghostty"
    "git"
    "lazygit"
    "nushell"
    "nvim"
    "ohmyposh"
    "shell"
    "sketchybar"
    "ssh"
    "starship"
    "tmux"
    "vim"
    "yazi"
    "zsh"
)

# Stow each package into its own subdirectory
STOWED=0
FAILED=0
for package in "${PACKAGES[@]}"; do
    if [ -d "$package" ]; then
        info "Stowing $package..."

        # Create target directory if it doesn't exist
        target_dir="$HOME/.config/$package"
        mkdir -p "$target_dir"

        # Stow into ~/.config/<package> to preserve directory structure
        if stow -d . -t "$target_dir" "$package" 2>/dev/null; then
            success "✓ $package"
            STOWED=$((STOWED + 1))
        else
            warn "✗ $package (conflicts exist, use 'stow -d . -t ~/.config/$package $package' to see details)"
            FAILED=$((FAILED + 1))
        fi
    fi
done

success "Stowed $STOWED packages successfully"
if [ $FAILED -gt 0 ]; then
    warn "$FAILED packages had conflicts"
fi

# ============================================
# CREATE HOME DIRECTORY SYMLINKS
# ============================================
info "Creating home directory symlinks..."

# Create symlinks for configs that need to be in home directory
SYMLINKS=(
    "$HOME/.bashrc:$HOME/.config/bash/.bashrc"
    "$HOME/.zshrc:$HOME/.config/zsh/.zshrc"
    "$HOME/.vimrc:$HOME/.config/vim/.vimrc"
    "$HOME/.gitconfig:$HOME/.config/git/.gitconfig"
)

for link_def in "${SYMLINKS[@]}"; do
    IFS=':' read -r link_path target_path <<< "$link_def"

    # Remove existing file/link if it exists
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then
        rm -f "$link_path"
    fi

    # Create symlink
    if [ -e "$target_path" ]; then
        ln -sf "$target_path" "$link_path"
        success "Linked: $(basename "$link_path")"
    else
        warn "Target does not exist: $target_path"
    fi
done

# SSH config requires the directory to exist
if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi

if [ -e "$HOME/.config/ssh/config" ]; then
    ln -sf "$HOME/.config/ssh/config" "$HOME/.ssh/config"
    success "Linked: .ssh/config"
fi

# Vim colors directory
if [ -e "$HOME/.config/vim/colors" ] && [ ! -e "$HOME/.vim/colors" ]; then
    mkdir -p "$HOME/.vim"
    ln -sf "$HOME/.config/vim/colors" "$HOME/.vim/colors"
    success "Linked: .vim/colors"
fi

# ============================================
# SET PERMISSIONS
# ============================================
info "Setting executable permissions..."

# Make tmux sessionizer executable
if [ -f "$HOME/.config/tmux/scripts/tmux-sessionizer" ]; then
    chmod +x "$HOME/.config/tmux/scripts/tmux-sessionizer"
    success "Set permissions: tmux-sessionizer"
fi

# Make all sketchybar plugins executable
if [ -d "$HOME/.config/sketchybar/plugins" ]; then
    chmod +x "$HOME/.config/sketchybar/plugins"/*
    success "Set permissions: sketchybar plugins"
fi

# ============================================
# POST-INSTALL INSTRUCTIONS
# ============================================
echo ""
success "Dotfiles installation complete!"
echo ""
info "Next steps:"
echo "  1. Install dependencies: brew bundle"
echo "  2. Restart your shell: exec \$SHELL"
echo "  3. Review shell config: ~/.config/shell/*.sh"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    info "Your old configs are backed up at:"
    echo "  $BACKUP_DIR"
    echo ""
fi

warn "Note: Some configurations may require additional setup:"
echo "  - Git: Configure identities in ~/.config/git/.gitconfig-*"
echo "  - SSH: Add your SSH keys to ~/.ssh/"
echo "  - GPG: Import your GPG keys if using signed commits"
echo "  - Nix: Set up nix-darwin if using Nix (optional)"
echo ""
