# Dotfiles

Personal configuration files for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Overview

This repository contains configuration files for:

- **Shell**: Bash, Zsh, Nushell
- **Editor**: Neovim, Vim
- **Terminal**: Ghostty, Tmux
- **Tools**: Git, SSH, Starship, Lazygit, Yazi, Direnv
- **macOS**: Aerospace (window manager), SketchyBar (status bar)

## Prerequisites

### Required

- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink manager
- [Homebrew](https://brew.sh/) - Package manager for macOS

### Recommended Tools

Install via Homebrew after setup:

```bash
brew bundle
```

See `Brewfile` for the complete list of dependencies including:
- `neovim` - Modern text editor
- `tmux` - Terminal multiplexer
- `fzf` - Fuzzy finder
- `bat` - Better cat
- `eza` - Modern ls
- `zoxide` - Smarter cd
- `starship` - Cross-shell prompt
- `direnv` - Environment switcher
- And many more...

### Optional

- [Nix](https://nixos.org/) with [nix-darwin](https://github.com/LnL7/nix-darwin) - Declarative system configuration
- [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI
- [yazi](https://github.com/sxyazi/yazi) - Terminal file manager

## Installation

### Fresh Install

1. **Clone this repository:**
   ```bash
   git clone <your-repo-url> ~/personal/dotfiles
   cd ~/personal/dotfiles
   ```

2. **Backup existing configs** (automatic):
   ```bash
   ./setup.sh
   ```

   This will:
   - Backup existing configs to `~/.dotfiles-backup-<timestamp>/`
   - Use stow to symlink all configurations to `~/.config/`
   - Set proper permissions for executable scripts
   - Create necessary symlinks to home directory

3. **Install dependencies:**
   ```bash
   brew bundle
   ```

4. **Restart your shell** or source the config:
   ```bash
   exec $SHELL
   # or
   source ~/.zshrc  # or ~/.bashrc
   ```

### Selective Installation

To install only specific configurations:

```bash
stow -t ~/.config <package-name>
```

For example:
```bash
stow -t ~/.config zsh
stow -t ~/.config nvim
stow -t ~/.config tmux
```

## Structure

Each directory represents a stow package that maps to `~/.config/<package>/`:

```
dotfiles/
├── aerospace/          # Aerospace window manager config
├── bash/              # Bash configuration
├── direnv/            # Direnv configuration
├── ghostty/           # Ghostty terminal config
├── git/               # Git config with multi-identity support
├── lazygit/           # Lazygit config
├── nushell/           # Nushell config
├── nvim/              # Neovim configuration
├── ohmyposh/          # Oh My Posh themes
├── sketchybar/        # SketchyBar config and plugins
├── ssh/               # SSH config
├── starship/          # Starship prompt config
├── tmux/              # Tmux config and scripts
├── vim/               # Vim config and colors
├── yazi/              # Yazi file manager config
├── zsh/               # Zsh configuration
├── setup.sh           # Installation script
├── uninstall.sh       # Uninstallation script
├── Brewfile           # Homebrew dependencies
└── README.md          # This file
```

## Configuration Highlights

### Multi-Identity Git Setup

The git configuration supports multiple identities based on directory:

- `~/work/**` → Work identity
- `~/work/phare/**` → Phare-specific identity
- `~/work/palantir/**` → Palantir-specific identity
- `~/personal/**` → Personal identity
- `~/.config/**` → Personal identity

Configure your identities in:
- `~/.config/git/.gitconfig-work`
- `~/.config/git/.gitconfig-personal`
- etc.

### Shell Features

Both Bash and Zsh configs include:

- **Vi mode** with `jj` to enter command mode
- **Smart completions** with case-insensitive matching
- **Modern CLI tools** (bat, eza, fzf, zoxide)
- **Kubernetes shortcuts** (k, kg, kd, etc.)
- **Docker aliases** (dco, dps, dx, etc.)
- **Tmux session management** (`sesh` command)
- **FZF integration** for fuzzy finding

### Tmux Session Manager

Quick session switching with `tmux-sessionizer`:

```bash
sesh              # Interactive project selector
personal          # Jump to ~/personal projects
work              # Jump to ~/work projects
```

Bound to `<C-f>` in tmux for quick access.

### Nix Integration

If using nix-darwin, helper functions are included:

```bash
nixswitch <config>  # Switch to a configuration
nixup <config>      # Update flake and switch
```

## Customization

### Adding New Configurations

1. Create a new directory: `mkdir -p <package>/.config/<tool>`
2. Add your config files
3. Run: `stow <package>`

### Modifying Existing Configs

Configs are symlinked, so edit them directly:

```bash
nvim ~/.config/nvim/init.lua  # Edits the repo file
```

Changes are immediately reflected in the repository.

## Shell-Specific Notes

### Shared Configuration

Common aliases, functions, and environment variables are shared between Bash and Zsh via:
- `~/.config/shell/aliases.sh`
- `~/.config/shell/functions.sh`
- `~/.config/shell/env.sh`

Shell-specific settings remain in their respective `.bashrc` or `.zshrc` files.

### Environment Detection

Configs detect:
- **macOS device type** (MacBook, Mac mini) for prompt customization
- **Nix installation** for proper PATH setup
- **Available tools** with graceful fallbacks

## Uninstalling

To remove all symlinks:

```bash
./uninstall.sh
```

This will:
- Remove all stow-managed symlinks
- Keep your config files in the repository
- Not delete any backups

To fully remove:
```bash
./uninstall.sh
rm -rf ~/personal/dotfiles
```

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:

```bash
# Remove conflicting files (after backing up!)
rm ~/.config/<conflicting-file>

# Re-run setup
./setup.sh
```

### Missing Dependencies

Check which tools are missing:

```bash
command -v nvim fzf bat eza zoxide starship | grep -q "not found"
```

Install missing tools:
```bash
brew bundle
```

### Shell Not Loading Config

Ensure symlinks are correct:

```bash
ls -la ~/.bashrc ~/.zshrc ~/.config
```

For Bash, check that `~/.bashrc` links to `~/.config/bash/.bashrc`.
For Zsh, check that `~/.zshrc` links to `~/.config/zsh/.zshrc`.

## Contributing

This is a personal dotfiles repository, but feel free to fork and adapt to your needs!

## License

MIT - Feel free to use and modify as needed.

## Acknowledgments

Inspired by the dotfiles community and various configurations from:
- ThePrimeagen (tmux sessionizer)
- Neovim community
- r/unixporn
