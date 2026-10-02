# ============================================
# ZSH OPTIONS
# ============================================
setopt prompt_subst

# ============================================
# COMPLETIONS
# ============================================
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit

# PLUGINS & EXTERNAL TOOLS
# ============================================
# Nix (load first so Nix-managed tools are available)
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
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
# ZSH-SPECIFIC KEY BINDINGS
# ============================================
# Autosuggestions (if zsh-autosuggestions is installed)
if [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    bindkey '^w' autosuggest-execute
    bindkey '^e' autosuggest-accept
    bindkey '^u' autosuggest-toggle
    bindkey '^L' vi-forward-word
fi

# Navigation
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey jj vi-cmd-mode

# ============================================
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
    eval "$(starship init zsh)"
    export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi

# FZF
if command -v fzf >/dev/null 2>&1; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    eval "$(fzf --zsh)"
fi

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Direnv
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# Mise
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# Cert Setup
# export REQUESTS_CA_BUNDLE="$HOME/nscacert_combined.pem"
# export NODE_EXTRA_CA_CERTS="$HOME/nscacert_combined.pem"
# export NIX_SSL_CERT_FILE='/etc/ssl/certs/ca-certificates-combined.crt'
export AZURE_CLI_DISABLE_CONNECTION_VERIFICATION=1

# Docker/Podman
# export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/podman.sock"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
export PATH="$HOME/personal/Odin:$PATH"

export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"

# Added by bifrost installer
export PATH="$HOME/.bifrost/bin:$PATH"
