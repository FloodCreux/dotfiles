#!/usr/bin/env sh
# ============================================
# SHARED FUNCTIONS
# Sourced by both Bash and Zsh
# ============================================

# ============================================
# NAVIGATION HELPERS
# ============================================

# cd and list
cx() {
    if [ $# -eq 0 ]; then
        echo "Usage: cx <directory>"
        return 1
    fi

    if [ ! -d "$1" ]; then
        echo "Error: Directory '$1' does not exist"
        return 1
    fi

    cd "$@" && ls
}

# Fuzzy cd into directory
fcd() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed"
        return 1
    fi

    local dir=$(find . -type d -not -path '*/.*' 2>/dev/null | fzf)
    if [ -n "$dir" ]; then
        cd "$dir" && ls
    fi
}

# Fuzzy find file and copy path to clipboard
f() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed"
        return 1
    fi

    local file=$(find . -type f -not -path '*/.*' 2>/dev/null | fzf)
    if [ -n "$file" ]; then
        echo "$file" | pbcopy
        echo "Copied: $file"
    fi
}

# Fuzzy find and edit file
fv() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed"
        return 1
    fi

    local file=$(find . -type f -not -path '*/.*' 2>/dev/null | fzf)
    if [ -n "$file" ]; then
        ${EDITOR:-vim} "$file"
    fi
}

# ============================================
# GIT HELPERS
# ============================================

# Update git remote URL
gpat() {
    if [ $# -eq 0 ]; then
        echo "Usage: gpat <new-remote-url>"
        return 1
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    git remote set-url origin "$1"
    echo "Remote URL updated to: $1"
}

# ============================================
# NIX DARWIN HELPERS
# ============================================

# Switch nix-darwin configuration
nixswitch() {
    if [ $# -eq 0 ]; then
        echo "Usage: nixswitch <configuration>"
        return 1
    fi

    if [ ! -d "$HOME/personal/nix" ]; then
        echo "Error: Nix configuration directory not found at ~/personal/nix"
        return 1
    fi

    if ! command -v darwin-rebuild >/dev/null 2>&1; then
        echo "Error: darwin-rebuild not found. Is nix-darwin installed?"
        return 1
    fi

    pushd ~/personal/nix >/dev/null || return 1
    sudo darwin-rebuild switch --flake ".#$1"
    local status=$?
    popd >/dev/null || return 1
    return $status
}

# Update nix flake and switch configuration
nixup() {
    if [ $# -eq 0 ]; then
        echo "Usage: nixup <configuration>"
        return 1
    fi

    if [ ! -d "$HOME/personal/nix" ]; then
        echo "Error: Nix configuration directory not found at ~/personal/nix"
        return 1
    fi

    if ! command -v nix >/dev/null 2>&1; then
        echo "Error: nix command not found"
        return 1
    fi

    pushd ~/personal/nix >/dev/null || return 1
    echo "Updating flake..."
    nix flake update

    if [ $? -eq 0 ]; then
        echo "Switching to configuration: $1"
        nixswitch "$1"
        local status=$?
        popd >/dev/null || return 1
        return $status
    else
        echo "Error: Failed to update flake"
        popd >/dev/null || return 1
        return 1
    fi
}
