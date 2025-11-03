# ============================================
# SHELL OPTIONS
# ============================================
setopt prompt_subst

# ============================================
# COMPLETIONS
# ============================================
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit

# ============================================
# ENVIRONMENT VARIABLES
# ============================================
export LANG=en_US.UTF-8
export EDITOR=/run/current-system/sw/bin/nvim
export XDG_CONFIG_HOME="$HOME/.config"

# Brew
export BREW_PREFIX="/opt/homebrew"

# Language-specific
export GOPATH="$HOME/go"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"

# Kubernetes
export KUBECONFIG=~/.kube/config

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'

# PATH
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$BREW_PREFIX/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.vimpkg/bin:$GOPATH/bin:$HOME/.cargo/bin"

# ============================================
# KEY BINDINGS
# ============================================
# Autosuggestions
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word

# Navigation
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey jj vi-cmd-mode

# ============================================
# PLUGINS & EXTERNAL TOOLS
# ============================================
# Nix (load first so Nix-managed tools are available)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Starship prompt
source ~/.config/zsh/starship.zsh
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Direnv
eval "$(direnv hook zsh)"

# ============================================
# ALIASES
# ============================================
# General
alias cl='clear'
alias cat='bat'
alias la='tree'
alias http='xh'

# Vim/Neovim
alias nvim='/run/current-system/sw/bin/nvim'
alias v='nvim'
alias vim='nvim'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Eza (modern ls)
alias ls='eza -l --icons --git -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias ltree='eza --tree --level=2 --icons --git'

# Git
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

# Docker
alias dco='docker compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias dl='docker ps -l -q'
alias dx='docker exec -it'

# Kubernetes
alias k='kubectl'
alias ka='kubectl apply -f'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kgpo='kubectl get pod'
alias kgd='kubectl get deployments'
alias kc='kubectx'
alias kns='kubens'
alias ke='kubectl exec -it'
alias kcns='kubectl config set-context --current --namespace'

# Tmux
alias sesh='sh ~/.config/tmux/scripts/tmux-sessionizer'
alias personal='sh ~/.config/tmux/scripts/tmux-sessionizer ~/personal'
alias work='sh ~/.config/tmux/scripts/tmux-sessionizer ~/work'
alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'

# Python
alias python='python3'

# Nmap
alias nm='nmap -sC -sV -oN nmap'

# ============================================
# FUNCTIONS
# ============================================
# Navigation helpers
cx() { cd "$@" && l; }

fcd() {
    local dir=$(find . -type d -not -path '*/.*' 2>/dev/null | fzf)
    [[ -n "$dir" ]] && cd "$dir" && l
}

f() { 
    echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy 
}

fv() { 
    nvim "$(find . -type f -not -path '*/.*' | fzf)" 
}

# Git remote URL update
gpat() {
    git remote set-url origin "$1"
}

# Nix Darwin helpers
nixswitch() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: nixswitch <configuration>"
        return 1
    fi
    pushd ~/personal/nix > /dev/null
    sudo darwin-rebuild switch --flake ".#$1"
    popd > /dev/null
}

nixup() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: nixup <configuration>"
        return 1
    fi
    pushd ~/personal/nix > /dev/null
    nix flake update
    nixswitch "$1"
    popd > /dev/null
}
