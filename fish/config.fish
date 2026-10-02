# ============================================
# FISH CONFIG
# Native port of shell/{env,aliases,functions}.sh + zsh/.zshrc
# (the shared .sh files are bash-isms and cannot be sourced by fish)
# ============================================

# ============================================
# ENVIRONMENT (all shells, like env.sh)
# ============================================
set -gx LANG en_US.UTF-8
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx KUBECONFIG $HOME/.kube/config
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow'
set -gx GOPATH $HOME/go
set -gx AZURE_CLI_DISABLE_CONNECTION_VERIFICATION 1

# Homebrew
if test -d /opt/homebrew
    set -gx BREW_PREFIX /opt/homebrew
else if test -d /usr/local
    set -gx BREW_PREFIX /usr/local
end

# Java
if test -d /opt/homebrew/opt/openjdk@17
    set -gx JAVA_HOME /opt/homebrew/opt/openjdk@17
else if test -d /usr/local/opt/openjdk@17
    set -gx JAVA_HOME /usr/local/opt/openjdk@17
end

# Java SSL trust store (for corporate SSL-inspection proxies like Netskope).
if set -q JAVA_HOME; and test -f $JAVA_HOME/lib/security/cacerts
    set -gx JAVA_TOOL_OPTIONS "-Djavax.net.ssl.trustStore=$JAVA_HOME/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
end

# PATH: rebuilt from existing dirs only (same order and replace semantics as env.sh)
set -l components \
    /nix/var/nix/profiles/default/bin \
    /run/current-system/sw/bin \
    $HOME/.npm-global/bin \
    $HOME/.local/bin \
    $BREW_PREFIX/bin \
    $BREW_PREFIX/opt/libpq/bin \
    /usr/local/bin \
    /usr/bin \
    /bin \
    /usr/sbin \
    /sbin \
    $HOME/.vimpkg/bin \
    $GOPATH/bin \
    $HOME/.cargo/bin \
    $HOME/.dotnet/tools \
    $HOME/.nix-profile/bin
set -l new_path
for dir in $components
    test -d $dir; and set -a new_path $dir
end
set -gx PATH $new_path

# EDITOR (computed after PATH so nvim is found)
if command -q nvim
    set -gx EDITOR (command -s nvim)
else if command -q vim
    set -gx EDITOR (command -s vim)
else
    set -gx EDITOR vi
end

# Nix (fish-native script)
set -l nix_fish /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
test -e $nix_fish; and source $nix_fish

# Extra PATH entries from the end of .zshrc
fish_add_path -g $HOME/personal/Odin /opt/homebrew/opt/util-linux/bin $HOME/.bifrost/bin

status is-interactive; or return

# ============================================
# INTERACTIVE ONLY
# ============================================
set -gx GPG_TTY (tty)
set -g fish_greeting # no greeting

# --------------------------------------------
# Key bindings
# zsh ends up in vi mode ($EDITOR contains "vi"), so mirror that here.
# --------------------------------------------
set -g fish_key_bindings fish_vi_key_bindings

function fish_user_key_bindings
    for mode in insert default
        bind -M $mode ctrl-k up-or-search
        bind -M $mode ctrl-j down-or-search
        bind -M $mode ctrl-e accept-autosuggestion
        bind -M $mode ctrl-w 'commandline -f accept-autosuggestion execute'
        bind -M $mode ctrl-l forward-word
    end
    # jj -> normal mode
    bind -M insert -m default jj backward-char force-repaint
end

# --------------------------------------------
# Prompt: starship + macOS device glyph
# --------------------------------------------
if test (uname) = Darwin
    # Cache device type (only detect once; shared with zsh)
    set -l cache $HOME/.cache/starship_device
    if not test -f $cache
        mkdir -p (dirname $cache)
        set -l device (system_profiler SPHardwareDataType 2>/dev/null | awk '/Model Name/ {print $3,$4,$5,$6,$7}')
        switch $device
            case '*MacBook*'
                echo \Uf0322 >$cache
            case '*mini*'
                echo \Uf01c4 >$cache
            case '*'
                echo "" >$cache
        end
    end
    set -gx STARSHIP_DEVICE (cat $cache)
    set -gx STARSHIP_DISTRO ""
end

if command -q starship
    set -gx STARSHIP_CONFIG $HOME/.config/starship/starship.toml
    starship init fish | source
end

# --------------------------------------------
# Tool integrations
# --------------------------------------------
command -q fzf; and fzf --fish | source
command -q zoxide; and zoxide init fish | source
command -q direnv; and direnv hook fish | source
command -q mise; and mise activate fish | source
command -q wt; and command wt config shell init fish | source

# --------------------------------------------
# Aliases (aliases.sh)
# --------------------------------------------
alias cl clear

command -q bat; and alias cat bat
command -q tree; and alias la tree
command -q xh; and alias http xh

if command -q nvim
    alias v nvim
    alias vim nvim
else if command -q vim
    alias v vim
else
    alias v nvim
end
alias vv '~/nvim-macos-arm64/bin/nvim'

# Navigation
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'

# eza
if command -q eza
    alias ls 'eza -l --icons --git -a'
    alias lt 'eza --tree --level=2 --long --icons --git'
    alias ltree 'eza --tree --level=2 --icons --git'
else if test (uname) = Darwin
    alias ls 'ls -lAhG'
else
    alias ls 'ls -lAh --color=auto'
end

# Git
alias gc 'git commit -m'
alias gca 'git commit -a -m'
alias gp 'git push origin HEAD'
alias gpu 'git pull origin'
alias gst 'git status'
alias glog "git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff 'git diff'
alias gco 'git checkout'
alias gb 'git branch'
alias gba 'git branch -a'
alias gadd 'git add'
alias ga 'git add -p'
alias gcoall 'git checkout -- .'
alias gr 'git remote'
alias gre 'git reset'

# Docker
if command -q docker
    alias dco 'docker compose'
    alias dps 'docker ps'
    alias dpa 'docker ps -a'
    alias dl 'docker ps -l -q'
    alias dx 'docker exec -it'
end

# Kubernetes
if command -q kubectl
    alias k kubectl
    alias ka 'kubectl apply -f'
    alias kg 'kubectl get'
    alias kd 'kubectl describe'
    alias kdel 'kubectl delete'
    alias kl 'kubectl logs'
    alias klf 'kubectl logs -f'
    alias kgpo 'kubectl get pod'
    alias kgd 'kubectl get deployments'
    alias ke 'kubectl exec -it'
    alias kcns 'kubectl config set-context --current --namespace'
end
command -q kubectx; and alias kc kubectx
command -q kubens; and alias kns kubens

# Tmux
if test -x $HOME/.config/tmux/scripts/tmux-sessionizer
    alias tmux-sesh 'sh ~/.config/tmux/scripts/tmux-sessionizer'
    alias personal 'sh ~/.config/tmux/scripts/tmux-sessionizer ~/personal'
    alias work 'sh ~/.config/tmux/scripts/tmux-sessionizer ~/work'
end
test -x $HOME/.config/tmux/scripts/tmux-cht; and alias tmux-chat 'sh ~/.config/tmux/scripts/tmux-cht'
command -q tmux; and alias mat 'osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'
test -x $HOME/.config/sesh/scripts/dev_layout.sh; and alias dev 'sh ~/.config/sesh/scripts/dev_layout.sh'

# Python / nmap
command -q python3; and alias python python3
command -q nmap; and alias nm 'nmap -sC -sV -oN nmap'

# --------------------------------------------
# Functions (functions.sh)
# --------------------------------------------

# cd and list
function cx -d "cd and list"
    if test (count $argv) -eq 0
        echo "Usage: cx <directory>"
        return 1
    end
    if not test -d $argv[1]
        echo "Error: Directory '$argv[1]' does not exist"
        return 1
    end
    cd $argv; and ls
end

# Fuzzy cd into directory
function fcd -d "Fuzzy cd into directory"
    if not command -q fzf
        echo "Error: fzf is not installed"
        return 1
    end
    set -l dir (find . -type d -not -path '*/.*' 2>/dev/null | fzf)
    if test -n "$dir"
        cd $dir; and ls
    end
end

# Fuzzy find file and copy path to clipboard
function f -d "Fuzzy find file, copy path to clipboard"
    if not command -q fzf
        echo "Error: fzf is not installed"
        return 1
    end
    set -l file (find . -type f -not -path '*/.*' 2>/dev/null | fzf)
    if test -n "$file"
        echo $file | pbcopy
        echo "Copied: $file"
    end
end

# Fuzzy find and edit file
function fv -d "Fuzzy find and edit file"
    if not command -q fzf
        echo "Error: fzf is not installed"
        return 1
    end
    set -l file (find . -type f -not -path '*/.*' 2>/dev/null | fzf)
    if test -n "$file"
        $EDITOR $file
    end
end

# Update git remote URL
function gpat -d "Update git remote URL"
    if test (count $argv) -eq 0
        echo "Usage: gpat <new-remote-url>"
        return 1
    end
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end
    git remote set-url origin $argv[1]
    echo "Remote URL updated to: $argv[1]"
end

# Switch nix-darwin configuration
function nixswitch -d "Switch nix-darwin configuration"
    if test (count $argv) -eq 0
        echo "Usage: nixswitch <configuration>"
        return 1
    end
    if not test -d $HOME/personal/nix
        echo "Error: Nix configuration directory not found at ~/personal/nix"
        return 1
    end
    if not command -q darwin-rebuild
        echo "Error: darwin-rebuild not found. Is nix-darwin installed?"
        return 1
    end
    pushd ~/personal/nix >/dev/null; or return 1
    sudo darwin-rebuild switch --flake ".#$argv[1]"
    set -l code $status
    popd >/dev/null
    return $code
end

# Update nix flake and switch configuration
function nixup -d "Update nix flake and switch configuration"
    if test (count $argv) -eq 0
        echo "Usage: nixup <configuration>"
        return 1
    end
    if not test -d $HOME/personal/nix
        echo "Error: Nix configuration directory not found at ~/personal/nix"
        return 1
    end
    if not command -q nix
        echo "Error: nix command not found"
        return 1
    end
    pushd ~/personal/nix >/dev/null; or return 1
    echo "Updating flake..."
    if nix flake update
        echo "Switching to configuration: $argv[1]"
        nixswitch $argv[1]
        set -l code $status
        popd >/dev/null
        return $code
    else
        echo "Error: Failed to update flake"
        popd >/dev/null
        return 1
    end
end
