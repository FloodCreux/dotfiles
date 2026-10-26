#!/usr/bin/env bash
# Shared helpers for setup.sh, uninstall.sh and install.sh. Source, don't run.
# shellcheck disable=SC2034  # variables are used by the sourcing scripts

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

header() {
    echo ""
    echo -e "${MAGENTA}========================================${NC}"
    echo -e "${MAGENTA}$1${NC}"
    echo -e "${MAGENTA}========================================${NC}"
    echo ""
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Every top-level directory is a stow package, stowed into ~/.config/<name>,
# except the names listed in .stow-packages-ignore.
discover_packages() {
    local ignore_file="$DOTFILES_DIR/.stow-packages-ignore"
    local dir name
    for dir in "$DOTFILES_DIR"/*/; do
        name="$(basename "$dir")"
        if [ -f "$ignore_file" ] && grep -qxF "$name" "$ignore_file"; then
            continue
        fi
        echo "$name"
    done
}

# Links outside ~/.config, as "link:target". Order matters: ~/.claude must
# exist before ~/.claude/CLAUDE.md.
HOME_LINKS=(
    "$HOME/.bashrc:$HOME/.config/bash/.bashrc"
    "$HOME/.zshrc:$HOME/.config/zsh/.zshrc"
    "$HOME/.vimrc:$HOME/.config/vim/.vimrc"
    "$HOME/.vim/colors:$HOME/.config/vim/colors"
    "$HOME/.gitconfig:$HOME/.config/git/.gitconfig"
    "$HOME/.ssh/config:$HOME/.config/ssh/config"
    "$HOME/.emacs:$HOME/.config/emacs/emacs.el"
    "$HOME/.emacs.d/early-init.el:$HOME/.config/emacs/early-init.el"
    "$HOME/.claude:$HOME/.config/claude"
    "$HOME/.AGENTS.md:$HOME/.config/ai/AGENTS.md"
    "$HOME/.claude/CLAUDE.md:$HOME/.config/ai/AGENTS.md"
)

DOOM_DIR="$HOME/.config/doom-emacs"
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
