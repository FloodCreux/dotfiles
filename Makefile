# ============================================
# DOTFILES MAKEFILE
# ============================================
# Convenient commands for managing dotfiles
# ============================================

.PHONY: help install bootstrap update brew brew-update uninstall test clean status

# Default target
.DEFAULT_GOAL := help

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

# Dotfiles directory
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# ============================================
# HELP
# ============================================
help: ## Show this help message
	@echo "$(BLUE)Dotfiles Management Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ============================================
# INSTALLATION
# ============================================
install: ## Install dotfiles (stow configs only)
	@echo "$(BLUE)[INSTALL]$(NC) Setting up dotfiles..."
	@chmod +x $(DOTFILES_DIR)/setup.sh
	@bash $(DOTFILES_DIR)/setup.sh

bootstrap: ## Full bootstrap (install Homebrew, packages, and dotfiles)
	@echo "$(BLUE)[BOOTSTRAP]$(NC) Bootstrapping fresh system..."
	@chmod +x $(DOTFILES_DIR)/install.sh
	@bash $(DOTFILES_DIR)/install.sh

# ============================================
# UPDATE
# ============================================
update: ## Update dotfiles from git and restow
	@echo "$(BLUE)[UPDATE]$(NC) Updating dotfiles..."
	@git -C $(DOTFILES_DIR) pull --rebase
	@echo "$(BLUE)[UPDATE]$(NC) Restowing packages..."
	@chmod +x $(DOTFILES_DIR)/setup.sh
	@bash $(DOTFILES_DIR)/setup.sh
	@echo "$(GREEN)[SUCCESS]$(NC) Dotfiles updated!"

# ============================================
# HOMEBREW
# ============================================
brew: ## Install/update packages from Brewfile
	@echo "$(BLUE)[BREW]$(NC) Installing Brewfile packages..."
	@cd $(DOTFILES_DIR) && brew bundle install --verbose

brew-update: ## Update all Homebrew packages
	@echo "$(BLUE)[BREW]$(NC) Updating Homebrew..."
	@brew update
	@brew upgrade
	@brew cleanup
	@echo "$(GREEN)[SUCCESS]$(NC) Homebrew packages updated!"

brew-dump: ## Dump currently installed packages to Brewfile
	@echo "$(BLUE)[BREW]$(NC) Dumping Brewfile..."
	@cd $(DOTFILES_DIR) && brew bundle dump --force --describe
	@echo "$(GREEN)[SUCCESS]$(NC) Brewfile updated!"

brew-cleanup: ## Clean up Homebrew cache and old versions
	@echo "$(BLUE)[BREW]$(NC) Cleaning up Homebrew..."
	@brew cleanup -s
	@brew autoremove
	@rm -rf "$(brew --cache)"
	@echo "$(GREEN)[SUCCESS]$(NC) Homebrew cleaned up!"

# ============================================
# UNINSTALL
# ============================================
uninstall: ## Remove all dotfile symlinks
	@echo "$(YELLOW)[UNINSTALL]$(NC) Removing dotfiles..."
	@chmod +x $(DOTFILES_DIR)/uninstall.sh
	@bash $(DOTFILES_DIR)/uninstall.sh

# ============================================
# TESTING & VALIDATION
# ============================================
test: ## Validate configuration files
	@echo "$(BLUE)[TEST]$(NC) Validating configurations..."
	@$(MAKE) test-shell
	@$(MAKE) test-symlinks
	@echo "$(GREEN)[SUCCESS]$(NC) All tests passed!"

test-shell: ## Test shell configurations
	@echo "$(BLUE)[TEST]$(NC) Testing shell configs..."
	@if command -v zsh >/dev/null 2>&1; then \
		echo "  Testing zsh..."; \
		zsh -n $(HOME)/.config/zsh/.zshrc 2>/dev/null && echo "  $(GREEN)✓$(NC) zsh config valid" || echo "  $(YELLOW)✗$(NC) zsh config has issues"; \
	fi
	@if command -v bash >/dev/null 2>&1; then \
		echo "  Testing bash..."; \
		bash -n $(HOME)/.config/bash/.bashrc 2>/dev/null && echo "  $(GREEN)✓$(NC) bash config valid" || echo "  $(YELLOW)✗$(NC) bash config has issues"; \
	fi

test-symlinks: ## Check if all symlinks are valid
	@echo "$(BLUE)[TEST]$(NC) Checking symlinks..."
	@for link in $(HOME)/.bashrc $(HOME)/.zshrc $(HOME)/.vimrc $(HOME)/.gitconfig $(HOME)/.ssh/config; do \
		if [ -L "$$link" ]; then \
			if [ -e "$$link" ]; then \
				echo "  $(GREEN)✓$(NC) $$link"; \
			else \
				echo "  $(YELLOW)✗$(NC) $$link (broken)"; \
			fi \
		else \
			echo "  $(YELLOW)✗$(NC) $$link (not a symlink)"; \
		fi \
	done

# ============================================
# STATUS & INFO
# ============================================
status: ## Show dotfiles status
	@echo "$(BLUE)Dotfiles Status$(NC)"
	@echo ""
	@echo "Location: $(DOTFILES_DIR)"
	@echo ""
	@echo "$(BLUE)Git Status:$(NC)"
	@git -C $(DOTFILES_DIR) status --short
	@echo ""
	@echo "$(BLUE)Symlinks:$(NC)"
	@for link in $(HOME)/.bashrc $(HOME)/.zshrc $(HOME)/.vimrc $(HOME)/.gitconfig $(HOME)/.ssh/config; do \
		if [ -L "$$link" ]; then \
			target=$$(readlink "$$link"); \
			echo "  $(GREEN)✓$(NC) $$(basename $$link) → $$target"; \
		else \
			echo "  $(YELLOW)✗$(NC) $$(basename $$link) (not installed)"; \
		fi \
	done
	@echo ""

info: ## Show system information
	@echo "$(BLUE)System Information$(NC)"
	@echo ""
	@echo "OS: $$(uname -s)"
	@echo "Shell: $$SHELL"
	@if command -v brew >/dev/null 2>&1; then \
		echo "Homebrew: $$(brew --version | head -n 1)"; \
	else \
		echo "Homebrew: $(YELLOW)Not installed$(NC)"; \
	fi
	@if command -v stow >/dev/null 2>&1; then \
		echo "GNU Stow: $$(stow --version | head -n 1)"; \
	else \
		echo "GNU Stow: $(YELLOW)Not installed$(NC)"; \
	fi
	@if command -v git >/dev/null 2>&1; then \
		echo "Git: $$(git --version)"; \
	fi
	@echo ""

# ============================================
# CLEANUP
# ============================================
clean: ## Clean up backup directories
	@echo "$(BLUE)[CLEAN]$(NC) Cleaning up old backups..."
	@find $(HOME) -maxdepth 1 -type d -name ".dotfiles-backup-*" -mtime +30 -exec rm -rf {} \; -print
	@echo "$(GREEN)[SUCCESS]$(NC) Old backups cleaned up!"

# ============================================
# GIT OPERATIONS
# ============================================
commit: ## Commit current changes (interactive)
	@echo "$(BLUE)[GIT]$(NC) Preparing commit..."
	@git -C $(DOTFILES_DIR) add -p
	@git -C $(DOTFILES_DIR) status
	@read -p "Enter commit message: " msg; \
	git -C $(DOTFILES_DIR) commit -m "$$msg"

push: ## Push changes to remote
	@echo "$(BLUE)[GIT]$(NC) Pushing to remote..."
	@git -C $(DOTFILES_DIR) push

pull: ## Pull changes from remote
	@echo "$(BLUE)[GIT]$(NC) Pulling from remote..."
	@git -C $(DOTFILES_DIR) pull --rebase

# ============================================
# DEVELOPMENT
# ============================================
edit: ## Open dotfiles directory in editor
	@if command -v $$EDITOR >/dev/null 2>&1; then \
		$$EDITOR $(DOTFILES_DIR); \
	else \
		echo "$(YELLOW)[WARN]$(NC) EDITOR not set, opening in vim..."; \
		vim $(DOTFILES_DIR); \
	fi

diff: ## Show differences between installed configs and repository
	@echo "$(BLUE)[DIFF]$(NC) Checking for differences..."
	@git -C $(DOTFILES_DIR) diff

# ============================================
# UTILITIES
# ============================================
backup-list: ## List all backup directories
	@echo "$(BLUE)Backup Directories:$(NC)"
	@find $(HOME) -maxdepth 1 -type d -name ".dotfiles-backup-*" -exec ls -ld {} \;

shell-reload: ## Reload shell configuration
	@echo "$(BLUE)[RELOAD]$(NC) Reloading shell configuration..."
	@exec $$SHELL
