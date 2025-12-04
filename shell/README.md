# Shared Shell Configuration

Common configuration shared between Bash and Zsh to avoid duplication.

## Files

### env.sh
Environment variables and PATH configuration:
- Language toolchain paths (Go, Java, Rust, etc.)
- Package manager setup (Homebrew, Nix)
- Editor detection with fallbacks
- Smart PATH building (only includes existing directories)

### aliases.sh
Common command aliases with dependency checking:
- Modern CLI tool replacements (bat, eza, fzf)
- Git shortcuts
- Docker and Kubernetes commands
- Navigation helpers
- All aliases check if the command exists before creating the alias

### functions.sh
Reusable shell functions:
- `cx <dir>` - Change directory and list contents
- `fcd` - Fuzzy find and cd into directory
- `f` - Fuzzy find file and copy path to clipboard
- `fv` - Fuzzy find and edit file
- `gpat <url>` - Update git remote URL
- `nixswitch <config>` - Switch nix-darwin configuration
- `nixup <config>` - Update nix flake and switch

All functions include error handling and dependency checks.

## Usage

These files are automatically sourced by `.bashrc` and `.zshrc`:

```bash
[ -f ~/.config/shell/env.sh ] && source ~/.config/shell/env.sh
[ -f ~/.config/shell/aliases.sh ] && source ~/.config/shell/aliases.sh
[ -f ~/.config/shell/functions.sh ] && source ~/.config/shell/functions.sh
```

## Customization

### Adding Shell-Specific Config

Keep shell-specific settings in `.bashrc` or `.zshrc`:
- Key bindings
- Completion systems
- Shell options
- Prompt configuration

### Adding Shared Config

Add to these files for cross-shell compatibility:
- Environment variables → `env.sh`
- Aliases → `aliases.sh`
- Functions → `functions.sh`

## Dependency Detection

All aliases and functions check for required commands:

```bash
# Example from aliases.sh
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# Example from functions.sh
fcd() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed"
        return 1
    fi
    # ... rest of function
}
```

This ensures the configs work even if some tools aren't installed.

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `v` | nvim/vim | Open editor |
| `..` | cd .. | Go up one directory |
| `gst` | git status | Git status |
| `gp` | git push origin HEAD | Push current branch |
| `k` | kubectl | Kubernetes CLI |
| `dco` | docker compose | Docker Compose |
| `sesh` | tmux-sessionizer | Tmux session switcher |

Run `alias` in your shell to see all aliases.

## Key Functions

| Function | Description |
|----------|-------------|
| `cx <dir>` | Change directory and list |
| `fcd` | Fuzzy find directory and cd |
| `fv` | Fuzzy find and edit file |
| `nixswitch` | Switch nix-darwin config |

## Environment Variables

Key variables set in `env.sh`:
- `EDITOR` - Your preferred editor (nvim → vim → vi)
- `XDG_CONFIG_HOME` - ~/.config
- `GOPATH` - ~/go
- `BREW_PREFIX` - /opt/homebrew or /usr/local
- `FZF_DEFAULT_COMMAND` - fd with hidden files
