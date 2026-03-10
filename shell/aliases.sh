#!/usr/bin/env sh
# ============================================
# SHARED ALIASES
# Sourced by both Bash and Zsh
# ============================================

# ============================================
# GENERAL
# ============================================
alias cl='clear'

# Use modern alternatives if available
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

if command -v tree >/dev/null 2>&1; then
    alias la='tree'
fi

if command -v xh >/dev/null 2>&1; then
    alias http='xh'
fi

# ============================================
# EDITOR
# ============================================
# Set vim/nvim aliases based on what's available
if command -v nvim >/dev/null 2>&1; then
    alias v='nvim'
    alias vim='nvim'
elif command -v vim >/dev/null 2>&1; then
    alias v='vim'
else
    alias v='nvim'
fi

# ============================================
# NAVIGATION
# ============================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# ============================================
# EZA (modern ls replacement)
# ============================================
if command -v eza >/dev/null 2>&1; then
    alias ls='eza -l --icons --git -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias ltree='eza --tree --level=2 --icons --git'
else
    # Fallback to regular ls with color
    if [[ "$OSTYPE" == "darwin"* ]]; then
        alias ls='ls -lAhG'
    else
        alias ls='ls -lAh --color=auto'
    fi
fi

# ============================================
# GIT
# ============================================
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gp='git push origin HEAD'
alias gpu='git pull origin'
alias gst='git status'
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# ============================================
# DOCKER
# ============================================
if command -v docker >/dev/null 2>&1; then
    alias dco='docker compose'
    alias dps='docker ps'
    alias dpa='docker ps -a'
    alias dl='docker ps -l -q'
    alias dx='docker exec -it'
fi

# ============================================
# KUBERNETES
# ============================================
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'
    alias ka='kubectl apply -f'
    alias kg='kubectl get'
    alias kd='kubectl describe'
    alias kdel='kubectl delete'
    alias kl='kubectl logs'
    alias klf='kubectl logs -f'
    alias kgpo='kubectl get pod'
    alias kgd='kubectl get deployments'
    alias ke='kubectl exec -it'
    alias kcns='kubectl config set-context --current --namespace'
fi

if command -v kubectx >/dev/null 2>&1; then
    alias kc='kubectx'
fi

if command -v kubens >/dev/null 2>&1; then
    alias kns='kubens'
fi

# ============================================
# TMUX
# ============================================
if [ -x "$HOME/.config/tmux/scripts/tmux-sessionizer" ]; then
    alias sesh='sh ~/.config/tmux/scripts/tmux-sessionizer'
    alias personal='sh ~/.config/tmux/scripts/tmux-sessionizer ~/personal'
    alias work='sh ~/.config/tmux/scripts/tmux-sessionizer ~/work'
fi

if command -v tmux >/dev/null 2>&1; then
    alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'
fi

# ============================================
# PYTHON
# ============================================
if command -v python3 >/dev/null 2>&1; then
    alias python='python3'
fi

# ============================================
# NMAP
# ============================================
if command -v nmap >/dev/null 2>&1; then
    alias nm='nmap -sC -sV -oN nmap'
fi
