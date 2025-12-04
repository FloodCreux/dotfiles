#!/usr/bin/env bash
# ============================================
# DOTFILES UNINSTALLATION SCRIPT
# ============================================
# This script removes all symlinks created by
# the setup script, restoring your system to
# its pre-dotfiles state.
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
# CONFIRMATION
# ============================================
warn "This will remove all dotfile symlinks from your system."
echo "The repository files will NOT be deleted."
echo ""
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Uninstall cancelled."
    exit 0
fi

# ============================================
# DEPENDENCY CHECKS
# ============================================
if ! command_exists stow; then
    warn "GNU Stow is not installed. Will only remove home directory symlinks."
fi

# ============================================
# GET DOTFILES DIRECTORY
# ============================================
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# ============================================
# UNSTOW PACKAGES
# ============================================
if command_exists stow; then
    info "Removing stowed configurations..."

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

    UNSTOWED=0
    for package in "${PACKAGES[@]}"; do
        if [ -d "$package" ]; then
            info "Unstowing $package..."
            if stow -D -t ~/.config "$package" 2>/dev/null; then
                success "✓ $package"
                UNSTOWED=$((UNSTOWED + 1))
            else
                warn "✗ $package (may not be stowed or already removed)"
            fi
        fi
    done

    success "Unstowed $UNSTOWED packages"
fi

# ============================================
# REMOVE HOME DIRECTORY SYMLINKS
# ============================================
info "Removing home directory symlinks..."

SYMLINKS=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/.ssh/config"
    "$HOME/.vim/colors"
)

REMOVED=0
for link_path in "${SYMLINKS[@]}"; do
    if [ -L "$link_path" ]; then
        # Check if it points to our dotfiles
        target=$(readlink "$link_path")
        if [[ "$target" == *".config/"* ]] || [[ "$target" == *"dotfiles/"* ]]; then
            rm "$link_path"
            success "Removed: $(basename "$link_path")"
            REMOVED=$((REMOVED + 1))
        else
            warn "Skipped: $(basename "$link_path") (points to: $target)"
        fi
    elif [ -e "$link_path" ]; then
        warn "Skipped: $(basename "$link_path") (not a symlink)"
    fi
done

if [ $REMOVED -gt 0 ]; then
    success "Removed $REMOVED symlinks"
else
    info "No symlinks found to remove"
fi

# ============================================
# CLEANUP EMPTY DIRECTORIES
# ============================================
info "Cleaning up empty directories..."

# Remove .vim directory if empty
if [ -d "$HOME/.vim" ] && [ -z "$(ls -A "$HOME/.vim")" ]; then
    rmdir "$HOME/.vim"
    success "Removed empty directory: ~/.vim"
fi

# ============================================
# FINAL MESSAGE
# ============================================
echo ""
success "Uninstallation complete!"
echo ""
info "Your dotfiles repository is still at:"
echo "  $DOTFILES_DIR"
echo ""
info "To restore your configurations from backup (if you have one):"
echo "  ls -d ~/.dotfiles-backup-* | tail -1  # Find latest backup"
echo "  cp -r ~/.dotfiles-backup-TIMESTAMP/home/YOUR_USER/.bashrc ~/.bashrc"
echo "  # Repeat for other files as needed"
echo ""
warn "Note: You may need to restart your shell or terminal for changes to take effect."
echo ""
