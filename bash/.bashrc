# ============================================
# BASH OPTIONS
# ============================================
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s dirspell
shopt -s cmdhist
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000

# ============================================
# COMPLETIONS
# ============================================
# Case-insensitive completion
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set colored-stats on'
bind 'set visible-stats on'
bind 'set mark-symlinked-directories on'
bind 'set colored-completion-prefix on'
bind 'set menu-complete-display-prefix on'

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Homebrew bash completion
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
  . "$BREW_PREFIX/etc/bash_completion"
fi

# ============================================
# SHARED CONFIGURATION
# Load environment variables, aliases, and functions
# shared between Bash and Zsh
# ============================================
[ -f ~/.config/shell/env.sh ] && source ~/.config/shell/env.sh
[ -f ~/.config/shell/aliases.sh ] && source ~/.config/shell/aliases.sh
[ -f ~/.config/shell/functions.sh ] && source ~/.config/shell/functions.sh

# ============================================
# BASH-SPECIFIC KEY BINDINGS
# ============================================
# Vi mode (similar to zsh's vi-cmd-mode)
set -o vi
# Use jj to enter command mode in vi insert mode
bind -m vi-insert '"jj": vi-movement-mode'

# Better history search
bind '"\C-k": previous-history'
bind '"\C-j": next-history'

# ============================================
# PLUGINS & EXTERNAL TOOLS
# ============================================
# Nix (load first so Nix-managed tools are available)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Bash autosuggestions (if available via homebrew)
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/bash-autosuggestions/bash-autosuggestions.sh" ]; then
    source "$BREW_PREFIX/share/bash-autosuggestions/bash-autosuggestions.sh"
fi

# Starship prompt - with device detection for macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Cache device type (only detect once)
    DEVICE_CACHE="$HOME/.cache/starship_device"
    if [[ ! -f "$DEVICE_CACHE" ]]; then
        mkdir -p "$(dirname "$DEVICE_CACHE")"
        _device=$(system_profiler SPHardwareDataType 2>/dev/null | awk '/Model Name/ {print $3,$4,$5,$6,$7}')
        case $_device in
            *MacBook*)  echo "󰌢" > "$DEVICE_CACHE";;
            *mini*)     echo "󰇄" > "$DEVICE_CACHE";;
            *)          echo "" > "$DEVICE_CACHE";;
        esac
    fi
    export STARSHIP_DEVICE="$(cat "$DEVICE_CACHE")"
    export STARSHIP_DISTRO=""
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
    export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi

# FZF
if command -v fzf >/dev/null 2>&1; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    eval "$(fzf --bash)"
fi

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# Direnv
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
