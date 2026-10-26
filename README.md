# Dotfiles

Personal macOS configuration, linked into place with [GNU Stow](https://www.gnu.org/software/stow/) and managed with [mise](https://mise.jdx.dev/) tasks.

## Install

Fresh Mac:

```bash
git clone git@github-personal:FloodCreux/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

`install.sh` installs Homebrew, Stow and mise, runs `setup.sh`, then (if you say yes) installs the Brewfile packages and mise tools.

Existing machine with Stow already installed:

```bash
./setup.sh        # or: mise run install
```

`setup.sh` is safe to re-run. Anything it would replace is copied to `~/.dotfiles-backup-<timestamp>/` first.

After installing:

1. Copy `git/.gitconfig-work.example` and `git/.gitconfig-codeberg.example` to the same names without `.example` and fill them in (see [git/README.md](git/README.md)).
2. Add SSH keys to `~/.ssh/` (see [ssh/README.md](ssh/README.md)).
3. Optionally run `mise run mac-defaults` and `mise run hooks`.

## How it works

Every top-level directory is a stow package, linked into `~/.config/<package>/`. For example, `nvim/init.lua` becomes `~/.config/nvim/init.lua`. Directories listed in `.stow-packages-ignore` are skipped.

A few tools expect files outside `~/.config`. `setup.sh` links those from the `HOME_LINKS` table in `lib.sh`:

| Link                                   | Points to                  |
| -------------------------------------- | -------------------------- |
| `~/.bashrc`                            | `~/.config/bash/.bashrc`   |
| `~/.zshrc`                             | `~/.config/zsh/.zshrc`     |
| `~/.vimrc`, `~/.vim/colors`            | `~/.config/vim/`           |
| `~/.gitconfig`                         | `~/.config/git/.gitconfig` |
| `~/.ssh/config`                        | `~/.config/ssh/config`     |
| `~/.emacs`, `~/.emacs.d/early-init.el` | `~/.config/emacs/`         |
| `~/.claude`                            | `~/.config/claude`         |
| `~/.AGENTS.md`, `~/.claude/CLAUDE.md`  | `~/.config/ai/AGENTS.md`   |

`setup.sh` also:

- links `~/opencode.jsonc` to the work opencode config, if `opencode/opencode.work.jsonc` exists (gitignored);
- clones [Doom Emacs](https://github.com/doomemacs/core) into `~/.config/doom-emacs` if missing (start it with `emacs --init-directory ~/.config/doom-emacs`);
- clones tpm into `~/.config/tmux/plugins/tpm` and installs tmux plugins;
- sets up the Bifrost gateway on work machines (see [bifrost/README.md](bifrost/README.md)).

## Packages

| Package      | What                                                        |
| ------------ | ----------------------------------------------------------- |
| `aerospace`  | Aerospace tiling window manager                             |
| `ai`         | Shared agent instructions (`AGENTS.md`)                     |
| `bash`       | Bash config                                                 |
| `bifrost`    | Local Bifrost AI gateway and its management script          |
| `claude`     | Claude Code settings and skills                             |
| `direnv`     | direnv config                                               |
| `emacs`      | Vanilla Emacs config                                        |
| `fish`       | Fish config                                                 |
| `ghostty`    | Ghostty terminal config and shaders                         |
| `git`        | Git config with per-directory identities                    |
| `lazygit`    | lazygit config                                              |
| `mise`       | Global mise tools (languages, CLIs, LSP servers)            |
| `nvim`       | Neovim config (native `vim.pack`, `lsp/` server configs)    |
| `opencode`   | opencode config                                             |
| `sesh`       | sesh tmux session manager config                            |
| `shell`      | Env, aliases and functions shared by Bash and Zsh           |
| `ssh`        | SSH config with per-account GitHub/Codeberg hosts           |
| `starship`   | Starship prompt                                             |
| `television` | television fuzzy finder and its channels                    |
| `tmux`       | tmux config and scripts (sessionizer, cht.sh)               |
| `tuicr`      | tuicr review tool config                                    |
| `vim`        | Vim config and colorschemes                                 |
| `worktrunk`  | worktrunk git worktree manager config                       |
| `yazi`       | yazi file manager config                                    |
| `zsh`        | Zsh config                                                  |

Not stowed: `mac/` (macOS defaults script) and `scripts/` (helpers for mise tasks).

## Tasks

Run `mise tasks` for the full list. The common ones:

```bash
mise run install       # stow everything and create home links
mise run update        # git pull, then re-run setup
mise run restow nvim   # restow one package
mise run status        # git status, home links, broken links
mise run uninstall     # remove every link (repo files are kept)
mise run brew          # install Brewfile packages
mise run brew-update   # update Homebrew packages
mise run lint          # shellcheck, taplo, stylua, gitleaks
mise run fmt           # format TOML and Lua
```

## Packages and tools

- **Homebrew** (`Brewfile`): system tools, libraries and GUI apps. Regenerate with `mise run brew-dump`.
- **mise** (`mise/config.toml`): language runtimes and dev CLIs. Install with `mise install`.
- **mise, repo-local** (`mise.toml`): only the linters used by `mise run lint`.

## Adding a package

1. Create a top-level directory named after the tool's `~/.config` directory, e.g. `mytool/`.
2. Put the files in it exactly as they should appear under `~/.config/mytool/`.
3. Run `mise run restow mytool` (or `./setup.sh`).
4. If the tool needs a file outside `~/.config`, add it to `HOME_LINKS` in `lib.sh`.

## Git identities

`git/.gitconfig` picks an identity by directory:

- `~/work/**` → `~/.config/git/.gitconfig-work`
- `~/personal/**` and `~/.config/**` → `~/.config/git/.gitconfig-codeberg`

## Troubleshooting

**Stow reports a conflict.** A real file exists where a link should go. `setup.sh` prints the conflicting paths; move them out of the way and re-run. To preview: `stow -n -v -d ~/personal/dotfiles -t ~/.config/<pkg> <pkg>`.

**A config isn't loading.** Run `mise run status` to check links, and `mise run check-links` for broken ones.

**Restoring a backup.** Backups keep paths relative to `$HOME`, e.g. `cp -R ~/.dotfiles-backup-<timestamp>/.zshrc ~/.zshrc`.

## License

MIT
