# ============================================
# DOTFILES JUSTFILE
# ============================================
# Convenient commands for managing dotfiles
# ============================================

# Default recipe (show help)
default: help

# Dotfiles directory
dotfiles_dir := justfile_directory()

# ============================================
# HELP
# ============================================

# Show this help message
help:
    @echo "Dotfiles Management Commands"
    @echo ""
    @just --list --unsorted
    @echo ""

# ============================================
# INSTALLATION
# ============================================

# Install dotfiles (stow configs only)
install:
    @echo "[INSTALL] Setting up dotfiles..."
    @chmod +x {{dotfiles_dir}}/setup.sh
    @bash {{dotfiles_dir}}/setup.sh

# Full bootstrap (install Homebrew, packages, and dotfiles)
bootstrap:
    @echo "[BOOTSTRAP] Bootstrapping fresh system..."
    @chmod +x {{dotfiles_dir}}/install.sh
    @bash {{dotfiles_dir}}/install.sh

# ============================================
# UPDATE
# ============================================

# Update dotfiles from git and restow
update:
    @echo "[UPDATE] Updating dotfiles..."
    @git -C {{dotfiles_dir}} pull --rebase
    @echo "[UPDATE] Restowing packages..."
    @chmod +x {{dotfiles_dir}}/setup.sh
    @bash {{dotfiles_dir}}/setup.sh
    @echo "[SUCCESS] Dotfiles updated!"

# ============================================
# HOMEBREW
# ============================================

# Install taps first, then install all packages from Brewfile (use on fresh system)
brew-setup:
    @echo "[BREW] Installing taps..."
    @cd {{dotfiles_dir}} && grep '^tap' Brewfile | sed 's/tap "/brew tap /;s/"$//' | bash
    @echo "[BREW] Installing Brewfile packages..."
    @cd {{dotfiles_dir}} && brew bundle install --verbose

# Install/update packages from Brewfile
brew:
    @echo "[BREW] Installing Brewfile packages..."
    @cd {{dotfiles_dir}} && brew bundle install --file ./Brewfile --verbose

# Update all Homebrew packages
brew-update: && fix-java-certs
    @echo "[BREW] Updating Homebrew..."
    @brew update
    @brew upgrade
    @brew cleanup
    @echo "[SUCCESS] Homebrew packages updated!"

# Dump currently installed packages to Brewfile
brew-dump:
    @echo "[BREW] Dumping Brewfile..."
    @cd {{dotfiles_dir}} && brew bundle dump --force --describe
    @echo "[SUCCESS] Brewfile updated!"

# Clean up Homebrew cache and old versions
brew-cleanup:
    @echo "[BREW] Cleaning up Homebrew..."
    @brew cleanup -s
    @brew autoremove
    @rm -rf "$(brew --cache)"
    @echo "[SUCCESS] Homebrew cleaned up!"

# ============================================
# UNINSTALL
# ============================================

# Remove all dotfile symlinks
uninstall:
    @echo "[UNINSTALL] Removing dotfiles..."
    @chmod +x {{dotfiles_dir}}/uninstall.sh
    @bash {{dotfiles_dir}}/uninstall.sh

# ============================================
# TESTING & VALIDATION
# ============================================

# Validate configuration files
test: test-shell test-symlinks
    @echo "[SUCCESS] All tests passed!"

# Test shell configurations
test-shell:
    @echo "[TEST] Testing shell configs..."
    @if command -v zsh >/dev/null 2>&1; then \
        echo "  Testing zsh..."; \
        zsh -n $HOME/.config/zsh/.zshrc 2>/dev/null && echo "  ✓ zsh config valid" || echo "  ✗ zsh config has issues"; \
    fi
    @if command -v bash >/dev/null 2>&1; then \
        echo "  Testing bash..."; \
        bash -n $HOME/.config/bash/.bashrc 2>/dev/null && echo "  ✓ bash config valid" || echo "  ✗ bash config has issues"; \
    fi

# Check if all symlinks are valid
test-symlinks:
    @echo "[TEST] Checking symlinks..."
    @for link in $HOME/.bashrc $HOME/.zshrc $HOME/.vimrc $HOME/.gitconfig $HOME/.ssh/config; do \
        if [ -L "$$link" ]; then \
            if [ -e "$$link" ]; then \
                echo "  ✓ $$link"; \
            else \
                echo "  ✗ $$link (broken)"; \
            fi \
        else \
            echo "  ✗ $$link (not a symlink)"; \
        fi \
    done

# ============================================
# STATUS & INFO
# ============================================

# Show dotfiles status
status:
    @echo "Dotfiles Status"
    @echo ""
    @echo "Location: {{dotfiles_dir}}"
    @echo ""
    @echo "Git Status:"
    @git -C {{dotfiles_dir}} status --short
    @echo ""
    @echo "Symlinks:"
    @for link in $HOME/.bashrc $HOME/.zshrc $HOME/.vimrc $HOME/.gitconfig $HOME/.ssh/config; do \
        if [ -L "$$link" ]; then \
            target=$$(readlink "$$link"); \
            echo "  ✓ $$(basename $$link) → $$target"; \
        else \
            echo "  ✗ $$(basename $$link) (not installed)"; \
        fi \
    done
    @echo ""

# Show system information
info:
    @echo "System Information"
    @echo ""
    @echo "OS: $(uname -s)"
    @echo "Shell: $SHELL"
    @if command -v brew >/dev/null 2>&1; then \
        echo "Homebrew: $(brew --version | head -n 1)"; \
    else \
        echo "Homebrew: Not installed"; \
    fi
    @if command -v stow >/dev/null 2>&1; then \
        echo "GNU Stow: $(stow --version | head -n 1)"; \
    else \
        echo "GNU Stow: Not installed"; \
    fi
    @if command -v git >/dev/null 2>&1; then \
        echo "Git: $(git --version)"; \
    fi
    @echo ""

# ============================================
# CLEANUP
# ============================================

# Clean up backup directories
clean:
    @echo "[CLEAN] Cleaning up old backups..."
    @find $HOME -maxdepth 1 -type d -name ".dotfiles-backup-*" -mtime +30 -exec rm -rf {} \; -print
    @echo "[SUCCESS] Old backups cleaned up!"

# ============================================
# GIT OPERATIONS
# ============================================

# Commit current changes (interactive)
commit:
    @echo "[GIT] Preparing commit..."
    @git -C {{dotfiles_dir}} add -p
    @git -C {{dotfiles_dir}} status
    @read -p "Enter commit message: " msg && git -C {{dotfiles_dir}} commit -m "$$msg"

# Push changes to remote
push:
    @echo "[GIT] Pushing to remote..."
    @git -C {{dotfiles_dir}} push

# Pull changes from remote
pull:
    @echo "[GIT] Pulling from remote..."
    @git -C {{dotfiles_dir}} pull --rebase

# ============================================
# DEVELOPMENT
# ============================================

# Open dotfiles directory in editor
edit:
    @if command -v $EDITOR >/dev/null 2>&1; then \
        $EDITOR {{dotfiles_dir}}; \
    else \
        echo "[WARN] EDITOR not set, opening in vim..."; \
        vim {{dotfiles_dir}}; \
    fi

# Show differences between installed configs and repository
diff:
    @echo "[DIFF] Checking for differences..."
    @git -C {{dotfiles_dir}} diff

# ============================================
# UTILITIES
# ============================================

# Import Netskope CA cert into all Homebrew JDK trust stores (needed for SSL inspection proxy)
fix-java-certs:
    @echo "[CERTS] Importing Netskope CA into JDK trust stores..."
    @CERT="/Library/Application Support/Netskope/STAgent/data/nscacert.pem"; \
    if [ ! -f "$CERT" ]; then \
        echo "[SKIP] Netskope cert not found — not behind SSL inspection proxy"; \
        exit 0; \
    fi; \
    for jdk in /opt/homebrew/opt/openjdk*/libexec/openjdk.jdk/Contents/Home /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home; do \
        CACERTS="$jdk/lib/security/cacerts"; \
        if [ ! -f "$CACERTS" ]; then continue; fi; \
        if keytool -list -keystore "$CACERTS" -storepass changeit -alias netskope-ca >/dev/null 2>&1; then \
            echo "  [OK] $jdk (already imported)"; \
        else \
            keytool -importcert -trustcacerts -alias netskope-ca \
                -file "$CERT" -keystore "$CACERTS" -storepass changeit -noprompt && \
            echo "  [OK] $jdk (imported)" || \
            echo "  [FAIL] $jdk"; \
        fi; \
    done; \
    echo "[SUCCESS] JDK trust stores updated!"

# List all backup directories
backup-list:
    @echo "Backup Directories:"
    @find $HOME -maxdepth 1 -type d -name ".dotfiles-backup-*" -exec ls -ld {} \;

# Reload shell configuration
shell-reload:
    @echo "[RELOAD] Reloading shell configuration..."
    @exec $SHELL
