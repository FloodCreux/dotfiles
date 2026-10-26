#!/usr/bin/env bash
# Show repo status, the links outside ~/.config, and broken links inside it.

set -uo pipefail

# shellcheck source=../lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

echo "Location: $DOTFILES_DIR"
echo ""
echo "Git status:"
git -C "$DOTFILES_DIR" status --short
echo ""

echo "Links outside ~/.config:"
for link_def in "${HOME_LINKS[@]}"; do
    IFS=':' read -r link_path target_path <<<"$link_def"
    name="${link_path#"$HOME"/}"
    if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target_path" ]; then
        if [ -e "$link_path" ]; then
            echo "  ✓ $name"
        else
            echo "  ✗ $name (broken)"
        fi
    elif [ -e "$link_path" ]; then
        echo "  ✗ $name (not linked by dotfiles)"
    else
        echo "  ✗ $name (missing)"
    fi
done
echo ""

echo "Broken links in ~/.config:"
broken="$(find "$HOME/.config" -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null)"
if [ -n "$broken" ]; then
    printf '  ✗ %s\n' "${broken//$'\n'/$'\n'  ✗ }"
else
    echo "  none"
fi
