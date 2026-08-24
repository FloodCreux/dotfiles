#!/usr/bin/env bash
tmux send-keys 'wt switch ^' Enter
tmux send-keys 'nvim' Enter
tmux split-window -h -c '#{pane_current_path}'
tmux send-keys 'wt switch ^' Enter
tmux send-keys 'opencode' Enter
tmux split-window -v -c '#{pane_current_path}'
tmux send-keys 'wt switch ^' Enter
tmux send-keys 'lazygit' Enter
tmux select-pane -t 0
