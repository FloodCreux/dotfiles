#!/usr/bin/env bash
# ============================================
# DOTFILES UNINSTALLATION SCRIPT
# ============================================
# Removes every link created by setup.sh.
# Repository files and backups are left alone.
# ============================================

set -euo pipefail

# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$DOTFILES_DIR"

warn "This will remove all dotfile symlinks from your system."
echo "The repository files will NOT be deleted."
echo ""
if [ "${1:-}" != "-y" ]; then
    read -p "Are you sure you want to continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Uninstall cancelled."
        exit 0
    fi
fi

# ============================================
# HOME DIRECTORY LINKS
# ============================================
# Removed first (in reverse) so ~/.claude/CLAUDE.md goes before ~/.claude.
info "Removing links outside ~/.config..."

REMOVED=0
for ((i = ${#HOME_LINKS[@]} - 1; i >= 0; i--)); do
    IFS=':' read -r link_path target_path <<<"${HOME_LINKS[$i]}"
    if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target_path" ]; then
        rm "$link_path"
        success "Removed: ${link_path#"$HOME"/}"
        REMOVED=$((REMOVED + 1))
    elif [ -e "$link_path" ] && [ ! -L "$link_path" ]; then
        warn "Skipped: ${link_path#"$HOME"/} (not a symlink)"
    fi
done

if [ -L "$HOME/opencode.jsonc" ]; then
    rm "$HOME/opencode.jsonc"
    success "Removed: opencode.jsonc"
    REMOVED=$((REMOVED + 1))
fi

info "Removed $REMOVED links"

# ============================================
# UNSTOW PACKAGES
# ============================================
if command_exists stow; then
    info "Removing stowed packages..."

    UNSTOWED=0
    while IFS= read -r package; do
        target_dir="$HOME/.config/$package"
        [ -d "$target_dir" ] || continue

        if stow -D -d . -t "$target_dir" "$package" 2>/dev/null; then
            success "✓ $package"
            UNSTOWED=$((UNSTOWED + 1))
            rmdir "$target_dir" 2>/dev/null || true
        else
            warn "✗ $package (run: stow -n -v -D -d $DOTFILES_DIR -t $target_dir $package)"
        fi
    done < <(discover_packages)

    success "Unstowed $UNSTOWED packages"
else
    warn "GNU Stow is not installed; skipping ~/.config packages."
fi

for dir in "$HOME/.vim" "$HOME/.emacs.d"; do
    rmdir "$dir" 2>/dev/null || true
done

echo ""
success "Uninstallation complete!"
echo ""
info "Your dotfiles repository is still at: $DOTFILES_DIR"
info "Not removed: $DOOM_DIR, $TPM_DIR, and the Bifrost launchd agent (bifrost-gateway down)."
info "To restore a backed-up file (paths are relative to \$HOME):"
echo "  ls -d ~/.dotfiles-backup-* | tail -1"
echo "  cp -R ~/.dotfiles-backup-TIMESTAMP/.zshrc ~/.zshrc"
echo ""
warn "Restart your shell or terminal for changes to take effect."
