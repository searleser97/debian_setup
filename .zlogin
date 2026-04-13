if command -v tmux &> /dev/null && [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
  echo
  if tmux has-session 2>/dev/null; then
    echo "Active tmux sessions:"
    echo
    tmux list-sessions
    echo
    echo "Hint: attach with  tmux attach -t <session-id>   (or just: tmux attach)"
  else
    echo "No active tmux sessions."
    echo "Hint: start one with  tmux"
  fi
  echo
fi
