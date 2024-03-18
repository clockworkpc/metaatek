#!/bin/bash

tmux new-session -d -s metaatek

tmux split-window -h

# Run commands in panes
tmux send-keys -t metaatek:1.0 'nvim' Enter
tmux send-keys -t metaatek:1.1 'cd ~/Development/metaatek' Enter './bin/dev' Enter

# Attach to the session
tmux attach-session -t metaatek
