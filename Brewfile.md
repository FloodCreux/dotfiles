# Brewfile Documentation

This Brewfile manages all Homebrew packages for the dotfiles setup. It uses a **leaf packages only** approach - only explicitly installed packages are listed, and Homebrew automatically handles dependencies.

## Table of Contents

- [Quick Start](#quick-start)
- [Custom Taps](#custom-taps)
- [Package Categories](#package-categories)
- [Usage Commands](#usage-commands)
- [Customization](#customization)

---

## Quick Start

```bash
# Install all packages from Brewfile
brew bundle

# Install with verbose output
brew bundle --verbose

# Check what's missing (dry run)
brew bundle check

# Cleanup packages not in Brewfile
brew bundle cleanup
```

Or use the justfile:

```bash
just brew-setup     # Fresh system: install taps first, then all packages
just brew           # Install/update Brewfile packages (taps already present)
just brew-update    # Update all packages
just brew-dump      # Export installed packages to Brewfile
just brew-cleanup   # Clean cache and old versions
```

> **Fresh system tip:** Use `just brew-setup` instead of `just brew` on a new machine.
> `brew bundle` will fail if taps aren't installed first, since formulae like `databricks`
> come from third-party taps. `brew-setup` installs all taps before running `brew bundle`.

---

## Custom Taps

Third-party repositories for packages not in the official Homebrew repos:

| Tap                           | Purpose                | Packages                         |
| ----------------------------- | ---------------------- | -------------------------------- |
| `azure/azd`                   | Azure Developer CLI    | azd                              |
| `azure/functions`             | Azure Functions tools  | azure-functions-core-tools@4     |
| `azure/kubelogin`             | Azure Kubernetes auth  | kubelogin                        |
| `coursier/formulas`           | Scala artifact fetcher | coursier (dependency)            |
| `databricks/tap`              | Databricks CLI         | databricks                       |
| `felixkratz/formulae`         | macOS custom bars      | sketchybar, borders              |
| `homebrew/bundle`             | Brewfile support       | bundler functionality            |
| `homebrew/services`           | Service management     | brew services commands           |
| `isen-ng/dotnet-sdk-versions` | .NET SDK versions      | dotnet (dependency)              |
| `koekeishiya/formulae`        | macOS window managers  | yabai, skhd (not currently used) |
| `nikitabobko/tap`             | Aerospace WM           | aerospace                        |
| `powershell/tap`              | PowerShell for macOS   | powershell                       |
| `scalacenter/bloop`           | Scala build server     | bloop                            |

---

## Package Categories

### ☁️ Cloud & DevOps (13 packages)

**Cloud Platforms:**

- `awscli` - AWS command-line interface
- `azure-cli` - Azure command-line interface
- `azd` - Azure Developer CLI (infrastructure as code)
- `azure-functions-core-tools@4` - Develop and test Azure Functions

**Data Engineering:**

- `databricks` - Databricks CLI for data/ML workflows
- `apache-spark` - Big data processing engine

**Container & Orchestration:**

- `docker` - Container platform
- `docker-compose` - Multi-container Docker apps
- `helm` - Kubernetes package manager
- `kubelogin` - Azure AD auth for Kubernetes

**Infrastructure:**

- `pass` - Unix password manager (GPG-based)
- `nmap` - Network security scanner
- `sqlcmd` - SQL Server command-line tool

---

### 💻 Development Tools

#### Build Systems & Compilers (10 packages)

- `cmake` / `cmake-docs` - Cross-platform build system
- `ninja` - Small build system with focus on speed
- `autoconf-archive` / `automake` - GNU build tools
- `ccache` - Compiler cache (speeds up recompilation)
- `nasm` - Netwide Assembler (x86/x64)
- `llvm` - Modular compiler infrastructure
- `gpatch` - GNU patch utility

#### Language Servers & LSP (3 packages)

- `lua-language-server` - Lua LSP for Neovim
- `rust-analyzer` - Rust LSP
- `jdtls` - Java language server (Eclipse JDT)

#### Version Managers (2 packages)

- `pyenv` - Python version management
- `opam` - OCaml package manager

---

### 🐍 Python Ecosystem (11 packages)

**Package Management:**

- `poetry` - Dependency management and packaging
- `pipx` - Install Python apps in isolated environments
- `uv` - Ultra-fast Python package installer (Rust-based)

**Code Quality:**

- `ruff` - ⚡ Fast Python linter/formatter (replaces black + isort + flake8)
- `black` - Opinionated code formatter (legacy, prefer ruff)
- `isort` - Import statement sorter (legacy, prefer ruff)
- `mypy` - Static type checker

**Development:**

- `python@3.11` - Python 3.11 runtime
- `jupyterlab` - Interactive notebook environment

**Dependencies:**

- `qt` - Cross-platform UI framework (JupyterLab dependency)

---

### ☕ Scala / JVM Ecosystem (5 packages)

- `bloop` - Scala build server (fast compilation)
- `mill` - Scala build tool (better than SBT for some projects)
- `openjdk@17` - Java Development Kit 17 (LTS)
- `coursier` - Dependency resolution (installed via tap)
- `apache-spark` - Big data with Scala support

---

### 🛠️ Shell Enhancements (7 packages)

**Modern CLI Replacements:**

- `eza` - Modern replacement for `ls` (colors, icons, git integration)
- `fd` - Modern replacement for `find` (fast, intuitive)
- `fzf` - Fuzzy finder (essential for workflows)
- `zoxide` - Smart `cd` command (learns your patterns)

**Shell Utilities:**

- `direnv` - Load/unload environment variables per directory
- `zsh-autosuggestions` - Fish-like autosuggestions for zsh
- `tmux` - Terminal multiplexer

---

### 📝 Text Editors & Related (5 packages)

- `stow` - Symlink farm manager (core dotfiles tool)
- `tree-sitter` / `tree-sitter-cli` - Parser generator for syntax highlighting
- `lua-language-server` - LSP for Neovim config
- `luarocks` - Lua package manager
- `lpeg` - Parsing expression grammars for Lua

---

### 🎨 Multimedia & Graphics (4 packages)

- `ffmpeg` - Video/audio processing Swiss army knife
- `imagemagick` - Image manipulation tool
- `ghostscript` - PostScript/PDF interpreter
- `raylib` - Game development library

---

### 🌐 Web & HTTP Tools (5 packages)

- `wget` - Non-interactive network downloader
- `httpie` - User-friendly HTTP client
- `xh` - Friendly HTTP client (Rust-based, faster than HTTPie)
- `gh` - GitHub CLI
- `gemini-cli` - Gemini protocol client

---

### 📚 Documentation & Diagrams (4 packages)

- `tectonic` - Modern TeX/LaTeX engine
- `mermaid-cli` - Generate diagrams from text (Mermaid syntax)
- `just` - Command runner (like make, but simpler)
- `jj` - Jujutsu version control (experimental Git alternative)

---

### 🍎 macOS-Specific Tools (3 packages)

- `aerospace` - Tiling window manager (i3-like for macOS)
- `sketchybar` - Custom menu bar replacement
- `borders` - Window border highlighter (integrates with window managers)

---

### 🖥️ System Info & Utilities (6 packages)

- `fastfetch` - System information tool (neofetch alternative)
- `opencode` - Open files in your editor from terminal
- `composer` - PHP dependency manager
- `codex` - AI code assistant
- `powershell` - PowerShell for macOS
- `libiconv` / `libev` - Library dependencies

---

## Casks (GUI Applications)

### Window Management & Productivity

- `aerospace` - Tiling window manager
- `raycast` - Spotlight replacement with plugins

### Terminal Emulators

- `ghostty` - Fast GPU-accelerated terminal
- `warp` - Modern terminal with AI features

### Web Browsers

- `zen` - Privacy-focused browser
- `zen-browser` - Alternative zen distribution

### Development Tools

- `dbeaver-community` - Universal database tool
- `devtoys` - Developer utilities (formatters, encoders, etc.)

### Font Tools

- `font-hack-nerd-font` - Patched font with icons
- `fontforge` / `fontforge-app` - Font editor

---

## Usage Commands

### Installation

```bash
# Install everything from Brewfile
brew bundle

# Install to specific location
brew bundle --file=/path/to/Brewfile

# Verbose output (see what's happening)
brew bundle --verbose

# Skip Cask applications
brew bundle --no-cask
```

### Checking Status

```bash
# Check if all packages are installed
brew bundle check

# Check and list missing packages
brew bundle check --verbose

# Check specific Brewfile
brew bundle check --file=~/dotfiles/Brewfile
```

### Cleanup

```bash
# Remove packages not in Brewfile (interactive)
brew bundle cleanup

# Force removal without confirmation
brew bundle cleanup --force

# Dry run (see what would be removed)
brew bundle cleanup --dry-run
```

### Updating

```bash
# Update Homebrew itself
brew update

# Upgrade all installed packages
brew upgrade

# Update Brewfile from installed packages
brew bundle dump --describe --force
```

---

## Customization

### Adding New Packages

1. Install the package:

   ```bash
   brew install package-name
   ```

2. Update Brewfile:

   ```bash
   make brew-dump
   # or
   brew bundle dump --describe --force
   ```

3. Commit changes:
   ```bash
   git add Brewfile
   git commit -m "Add package-name to Brewfile"
   ```

### Removing Packages

1. Remove from Brewfile (edit manually or use cleanup)

2. Uninstall the package:

   ```bash
   brew uninstall package-name
   ```

3. Clean up dependencies:
   ```bash
   brew autoremove
   ```

### Machine-Specific Packages

If you need different packages on different machines:

1. Create a `Brewfile.local`:

   ```ruby
   # Machine-specific packages
   brew "specific-tool"
   ```

2. Install both:

   ```bash
   brew bundle
   brew bundle --file=Brewfile.local
   ```

3. Add `Brewfile.local` to `.gitignore`

---

## Package Count Summary

- **Taps:** 13 custom repositories
- **Formulae:** 75 CLI tools and libraries
- **Casks:** 11 GUI applications
- **Total:** ~95 explicit packages (plus automatic dependencies)

---

## Notes

### Why Leaf Packages Only?

This Brewfile only lists **explicitly installed** packages. Dependencies are automatically managed by Homebrew, which:

- Reduces file size and maintenance
- Prevents version conflicts
- Makes updates easier
- Keeps the file focused on your actual choices

### Python Formatter Migration

**Note:** `black` and `isort` are legacy entries. The setup has migrated to `ruff` which provides:

- ⚡ 10-100x faster performance
- Combined linting + formatting
- Drop-in replacement for black, isort, flake8, and more

These may be removed in a future cleanup.

### Package Manager Philosophy

Where multiple tools exist for the same purpose:

- `eza` over `ls` - Better defaults, Git integration
- `fd` over `find` - Simpler syntax, faster
- `xh` over `httpie` - Rust performance, same UX
- `ruff` over `black`+`isort` - Speed and consolidation
- `uv` over `pip` - 10-100x faster installs

---

## Troubleshooting

### Conflicts During Installation

```bash
# See what's causing conflicts
brew bundle check --verbose

# Force reinstall
brew reinstall package-name

# Link manually
brew link package-name --force
```

### Outdated Packages

```bash
# Check for outdated packages
brew outdated

# Update specific package
brew upgrade package-name

# Update everything
make brew-update
```

### Disk Space Issues

```bash
# Clean up old versions
brew cleanup

# Remove cache entirely
make brew-cleanup

# See what's taking space
brew cleanup -n  # dry run
```

---

## Related Files

- `install.sh` - Bootstrap script that runs `brew bundle`
- `Makefile` - Convenient commands for brew operations
- `setup.sh` - Dotfiles installation (depends on `stow` from this Brewfile)

---

**Last Updated:** 2025-12-22
