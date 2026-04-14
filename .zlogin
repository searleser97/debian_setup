if command -v zellij &> /dev/null && [ -n "$SSH_CONNECTION" ] && [ -z "$ZELLIJ" ]; then
  echo
  local sessions=$(zellij list-sessions --short 2>/dev/null)
  if [ -n "$sessions" ]; then
    echo "Active zellij sessions:"
    echo
    zellij list-sessions
    echo
    echo "Hint: attach with  zellij attach <session-name>   (or just: zellij attach)"
  else
    echo "No active zellij sessions."
    echo "Hint: start one with  zellij"
  fi
  echo
fi
