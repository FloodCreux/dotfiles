# Tmux Configuration

Custom tmux configuration with vim-style keybindings and a session manager.

## Key Features

- **Prefix**: `Ctrl-a` (instead of default `Ctrl-b`)
- **Vi mode**: Navigate and copy with vim keybindings
- **Session persistence**: Don't exit when closing a session
- **Large history**: 1,000,000 lines
- **Mouse support**: Enabled
- **Status bar**: Minimalist design at top

## Key Bindings

### Session Management
- `Ctrl-a Ctrl-f` - Launch tmux-sessionizer (fuzzy find projects)
- `Ctrl-a d` - Detach from session

### Window Management
- `Ctrl-a c` - Create new window
- `Ctrl-a ,` - Rename window
- `Ctrl-a n` - Next window
- `Ctrl-a p` - Previous window
- `Ctrl-a 1-9` - Jump to window number

### Pane Management
- `Ctrl-a |` - Split horizontally
- `Ctrl-a -` - Split vertically
- `Ctrl-a h/j/k/l` - Navigate panes (vim-style)
- `Ctrl-a H/J/K/L` - Resize panes
- `Ctrl-a z` - Zoom/unzoom pane
- `Ctrl-a x` - Close pane

### Copy Mode (Vi-style)
- `Ctrl-a [` - Enter copy mode
- `v` - Start selection
- `y` - Copy selection
- `Ctrl-a ]` - Paste

## Tmux Session Manager

The `tmux-sessionizer` script provides quick project switching:

### Usage

```bash
# Interactive fuzzy finder
sesh

# Quick jump to personal projects
personal

# Quick jump to work projects
work
```

### How It Works

1. Searches predefined directories for projects:
   - `~/work`
   - `~/work/sandbox`
   - `~/personal`
   - `~/.config`

2. Uses fzf for fuzzy finding
3. Creates or switches to a tmux session named after the project
4. Changes to the project directory

### Customization

Edit `tmux/scripts/tmux-sessionizer` to add your own directories:

```bash
selected=$(find ~/work ~/custom/path ~/another/path -mindepth 1 -maxdepth 2 -type d | fzf)
```

## Status Bar

The status bar shows:
- **Left**: Session name (yellow highlight for current)
- **Right**: Time in HH:MM format
- **Windows**: Index and name, highlighted when active

## Configuration Files

- `tmux.conf` - Main configuration
- `tmux.reset.conf` - Reset to sensible defaults (sourced first)
- `scripts/tmux-sessionizer` - Session management script

## Tips

**Reload config:**
```bash
tmux source ~/.config/tmux/tmux.conf
# or from within tmux:
Ctrl-a : source ~/.config/tmux/tmux.conf
```

**List all sessions:**
```bash
tmux ls
```

**Attach to existing session:**
```bash
tmux attach -t session-name
```

**Kill a session:**
```bash
tmux kill-session -t session-name
```
