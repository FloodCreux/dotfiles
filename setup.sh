#!/usr/bin/env bash
# ============================================
# DOTFILES INSTALLATION SCRIPT
# ============================================
# Stows every package into ~/.config/<package>,
# creates the links that must live outside
# ~/.config, and installs plugins. Safe to re-run.
# ============================================

set -euo pipefail

# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$DOTFILES_DIR"

# ============================================
# DEPENDENCY CHECKS
# ============================================
if ! command_exists stow; then
    error "GNU Stow is not installed!"
    info "Install with: brew install stow"
    exit 1
fi

BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Copy a path into the backup dir, keeping its location relative to $HOME.
backup() {
    local path="$1"
    local dest="$BACKUP_DIR/${path#"$HOME"/}"
    mkdir -p "$(dirname "$dest")"
    cp -R "$path" "$dest"
    info "Backed up: $path"
}

# ============================================
# STOW PACKAGES
# ============================================
header "Stowing packages"

STOWED=0
FAILED=()
while IFS= read -r package; do
    target_dir="$HOME/.config/$package"
    mkdir -p "$target_dir"

    if output="$(stow -d . -t "$target_dir" "$package" 2>&1)"; then
        success "✓ $package"
        STOWED=$((STOWED + 1))
    else
        warn "✗ $package"
        printf '    %s\n' "${output//$'\n'/$'\n'    }"
        FAILED+=("$package")
    fi
done < <(discover_packages)

success "Stowed $STOWED packages"
if [ ${#FAILED[@]} -gt 0 ]; then
    warn "Conflicts in: ${FAILED[*]}"
    info "Move the listed files out of the way, then re-run. Details:"
    info "  stow -n -v -d $DOTFILES_DIR -t ~/.config/<pkg> <pkg>"
fi

# ============================================
# HOME DIRECTORY LINKS
# ============================================
header "Linking files outside ~/.config"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Left behind by older versions of this script.
if [ -L "$HOME/.claude/.CLAUDE.md" ]; then
    rm -f "$HOME/.claude/.CLAUDE.md"
fi

for link_def in "${HOME_LINKS[@]}"; do
    IFS=':' read -r link_path target_path <<<"$link_def"

    if [ ! -e "$target_path" ]; then
        warn "Target does not exist, skipping: $target_path"
        continue
    fi

    if [ -L "$link_path" ]; then
        rm -f "$link_path"
    elif [ -e "$link_path" ]; then
        backup "$link_path"
        rm -rf "$link_path"
    fi

    mkdir -p "$(dirname "$link_path")"
    ln -s "$target_path" "$link_path"
    success "Linked: ${link_path#"$HOME"/}"
done

# Only present on machines with the work opencode config.
if [ -e "$HOME/.config/opencode/opencode.work.jsonc" ]; then
    ln -sfn "$HOME/.config/opencode/opencode.work.jsonc" "$HOME/opencode.jsonc"
    success "Linked: opencode.jsonc (work)"
elif [ -L "$HOME/opencode.jsonc" ]; then
    rm -f "$HOME/opencode.jsonc"
fi

# ============================================
# DOOM EMACS
# ============================================
header "Doom Emacs"

if [ -d "$DOOM_DIR" ]; then
    success "Doom Emacs present at $DOOM_DIR"
elif command_exists git; then
    info "Cloning Doom Emacs into $DOOM_DIR..."
    if git clone --depth 1 https://github.com/doomemacs/core "$DOOM_DIR"; then
        success "Cloned Doom Emacs (run: $DOOM_DIR/bin/doom install)"
    else
        warn "Could not clone Doom Emacs"
    fi
fi

# ============================================
# TMUX PLUGINS
# ============================================
header "Tmux plugins"

if [ ! -d "$TPM_DIR" ] && command_exists git; then
    info "Cloning tpm into $TPM_DIR..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" || warn "Could not clone tpm"
fi

if [ -x "$TPM_DIR/bin/install_plugins" ]; then
    "$TPM_DIR/bin/install_plugins" || warn "tpm plugin install failed"
fi

# ============================================
# BIFROST GATEWAY
# ============================================
# Work machines only. The launcher config is merged (not symlinked) because
# the launcher rewrites it; the gateway runs as a launchd agent.
if [ -e "$HOME/.config/opencode/opencode.work.jsonc" ]; then
    header "Bifrost gateway"
    if "$DOTFILES_DIR/bifrost/bin/bifrost-gateway" setup; then
        success "Bifrost gateway installed (check with: bifrost-gateway doctor)"
    else
        warn "Bifrost gateway setup incomplete (run: bifrost-gateway doctor)"
    fi
fi

# ============================================
# Rex
# ============================================
rex config reload

# ============================================
# DONE
# ============================================
echo ""
success "Dotfiles installation complete!"
echo ""
info "Next steps:"
echo "  1. Install packages:  mise run brew && mise install"
echo "  2. Restart your shell: exec \$SHELL"
echo "  3. Git identities:    copy git/.gitconfig-*.example to git/.gitconfig-* and fill them in"
echo "  4. SSH keys:          add them to ~/.ssh/"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    info "Replaced files were backed up to: $BACKUP_DIR"
fi
