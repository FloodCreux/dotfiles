# Changelog

All notable improvements to this dotfiles repository.

## [2025-12-04] - Major Refactoring

### Added

#### Documentation
- **README.md** - Comprehensive guide covering installation, structure, features, and troubleshooting
- **CHANGELOG.md** - This file, documenting all changes
- **Brewfile** - Complete dependency list for Homebrew with categorized packages
- **git/README.md** - Multi-identity git setup documentation
- **tmux/README.md** - Tmux configuration and keybindings guide
- **shell/README.md** - Shared shell configuration documentation
- **ssh/README.md** - SSH configuration best practices

#### Scripts
- **setup.sh** - Complete rewrite with:
  - Automatic backup of existing configs (timestamped)
  - Proper stow usage for each package
  - Error checking and validation
  - Colored output and progress indicators
  - Permission management
  - Post-install instructions
- **uninstall.sh** - Clean removal of all dotfile symlinks

#### Configuration
- **shell/** directory - New shared configuration to eliminate duplication:
  - `env.sh` - Environment variables with smart PATH building
  - `aliases.sh` - Common aliases with dependency checking
  - `functions.sh` - Reusable functions with error handling
- **.gitconfig-*.example** - Template files for git identities

### Changed

#### Shell Configurations
- **Refactored .bashrc** - Reduced from 249 to 110 lines (56% reduction)
- **Refactored .zshrc** - Reduced from 199 to 85 lines (57% reduction)
- Both now source shared configs from `shell/` directory
- Removed starship.zsh (logic integrated into shell configs)
- Added conditional checks for Nix paths
- Added graceful fallbacks for missing tools

#### Git Configuration
- **Removed hardcoded personal information** from `.gitconfig`
- Git push aliases now use environment variables
- Added validation to aliases
- Created example templates for identity files

#### Setup Process
- **Fixed stow usage** - Now correctly stows individual packages
- **Removed manual symlinks** - All managed through stow except necessary home directory links
- **Added backup mechanism** - Automatic timestamped backups
- **Improved error handling** - Clear error messages and validation

### Security

- **Secured git identities** - Personal emails and GPG keys moved to ignored files
- **Updated .gitignore** - Now ignores:
  - Personal git identity files
  - SSH keys
  - Shell history
  - Editor/IDE files
  - Cache directories
  - macOS system files
- **Added .example templates** - Safe templates to commit without exposing personal data

### Improved

#### Error Handling
- All shell functions now check for:
  - Required dependencies
  - Directory existence
  - Command success/failure
- Functions return proper exit codes
- Clear error messages guide users

#### Dependency Management
- All aliases check if commands exist before aliasing
- Graceful fallbacks (e.g., `nvim` → `vim` → `vi`)
- Setup script validates dependencies before running
- Brewfile provides single source of truth for dependencies

#### Code Quality
- Eliminated ~300 lines of duplicated code
- Consistent formatting across all files
- Clear section headers and organization
- Comprehensive inline comments

## Migration Notes

### For Existing Users

1. **Backup your current configs** (setup.sh does this automatically)

2. **Create your identity files** from templates:
   ```bash
   cp git/.gitconfig-personal.example git/.gitconfig-personal
   # Edit with your information
   ```

3. **Set environment variables** if using git push aliases:
   ```bash
   export GIT_PERSONAL_EMAIL="your@email.com"
   export GIT_PERSONAL_KEY="YOUR_KEY_ID"
   ```

4. **Re-run setup**:
   ```bash
   ./setup.sh
   ```

5. **Install dependencies**:
   ```bash
   brew bundle
   ```

### Breaking Changes

- Old setup script behavior changed completely
- Git aliases now require environment variables
- Personal git config files are now gitignored
- Shell configs now depend on shared files in `shell/`

## Statistics

- **Files Added**: 13 (READMEs, scripts, shared configs)
- **Lines Reduced**: ~300 lines of duplicate code eliminated
- **Documentation**: ~1000 lines of documentation added
- **Security**: Personal data removed from 3 files
- **Dependencies**: 40+ packages documented in Brewfile

## Future Improvements

Potential additions:
- Automated testing of shell functions
- Installation script for other platforms (Linux)
- More comprehensive git aliases
- Integration with dotfiles management tools
- CI/CD for validation
