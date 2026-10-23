#!/usr/bin/env bash
pane="${TMUX_PANE:?must run inside tmux}"
right=$(tmux split-window -h -t "$pane" -c "$PWD" -P -F '#{pane_id}')
tmux send-keys -t "$right" opencode Enter
tmux select-pane -t "$pane"
nvim
