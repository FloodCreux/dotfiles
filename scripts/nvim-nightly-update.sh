#!/usr/bin/env bash

set -euo pipefail

REPO="neovim/neovim"
ASSET="nvim-macos-arm64.tar.gz"
DEST="$HOME/nvim-macos-arm64"

remote="$(gh api "repos/$REPO/git/ref/tags/nightly" --jq '.object.sha')"

installed=""
if [ -x "$DEST/bin/nvim" ]; then
    installed="$("$DEST/bin/nvim" --version | sed -n '1s/.*+g\([0-9a-f]*\).*/\1/p')"
fi

if [ "${1:-}" != "--force" ] && [ -n "$installed" ] && [[ "$remote" == "$installed"* ]]; then
    echo "Already on the latest nightly ($installed)."
    exit 0
fi

echo "Updating nvim: ${installed:-none} -> ${remote:0:10}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

gh release download nightly -R "$REPO" -p "$ASSET" -D "$tmp"
tar -xzf "$tmp/$ASSET" -C "$tmp"

"$tmp/nvim-macos-arm64/bin/nvim" --version | head -1

rm -rf "$DEST.old"
[ -d "$DEST" ] && mv "$DEST" "$DEST.old"
mv "$tmp/nvim-macos-arm64" "$DEST"
rm -rf "$DEST.old"

echo "Installed: $("$DEST/bin/nvim" --version | head -1)"
