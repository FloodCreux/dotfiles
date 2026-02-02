#!/usr/bin/env sh
# ============================================
# SHARED ENVIRONMENT VARIABLES
# Sourced by both Bash and Zsh
# ============================================

export LANG=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"
export GPG_TTY=$(tty)

# ============================================
# EDITOR
# ============================================
# Prefer Nix-managed nvim, fall back to system nvim, then vim
if [ -x "/run/current-system/sw/bin/nvim" ]; then
    export EDITOR="/run/current-system/sw/bin/nvim"
elif command -v nvim >/dev/null 2>&1; then
    export EDITOR="$(command -v nvim)"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="$(command -v vim)"
else
    export EDITOR="vi"
fi

# ============================================
# PACKAGE MANAGERS
# ============================================
# Homebrew
if [ -d "/opt/homebrew" ]; then
    export BREW_PREFIX="/opt/homebrew"
elif [ -d "/usr/local" ]; then
    export BREW_PREFIX="/usr/local"
fi

# ============================================
# LANGUAGE-SPECIFIC
# ============================================
export GOPATH="$HOME/go"

# Java - check if installed via Homebrew
if [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
elif [ -d "/usr/local/opt/openjdk@17" ]; then
    export JAVA_HOME="/usr/local/opt/openjdk@17"
fi

# ============================================
# TOOLS
# ============================================
# Kubernetes
export KUBECONFIG=~/.kube/config

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'

# ============================================
# PATH CONSTRUCTION
# ============================================
# Build PATH with components that exist
PATH_COMPONENTS=(
    "/run/current-system/sw/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
    "${BREW_PREFIX}/bin"
    "${BREW_PREFIX}/opt/libpq/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
    "$HOME/.vimpkg/bin"
    "$GOPATH/bin"
    "$HOME/.cargo/bin"
    "$HOME/.dotnet/tools"
)

# Rebuild PATH with only existing directories
NEW_PATH=""
for dir in "${PATH_COMPONENTS[@]}"; do
    # Expand variables
    dir=$(eval echo "$dir")
    if [ -d "$dir" ]; then
        if [ -z "$NEW_PATH" ]; then
            NEW_PATH="$dir"
        else
            NEW_PATH="$NEW_PATH:$dir"
        fi
    fi
done

export PATH="$NEW_PATH"
