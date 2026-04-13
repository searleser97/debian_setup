export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="jonathan"

export NVM_DIR="$HOME/.nvm"
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('nvim')

plugins=(git zsh-nvm)
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source $ZSH/oh-my-zsh.sh
fi

# Android SDK
export ANDROID=$HOME/Android
export PATH=$ANDROID/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID/platform-tools:$PATH

# Add .NET Core SDK tools
export PATH=$HOME/.dotnet/tools:$PATH
export PATH=$HOME/.dotnet:$PATH
export PATH=$HOME/ProgramFiles/netcoredbg:$PATH
export DOTNET_ROOT=$HOME/.dotnet

# Add my executables to the path
export PATH=$HOME/.local/bin:$PATH
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"

# Set git credential manager store mode
# export GCM_CREDENTIAL_STORE=cache

# Cross-platform fd command
if [[ "$OSTYPE" == "darwin"* ]]; then
    FD_CMD="fd"
else
    FD_CMD="fdfind"
fi

export FZF_DEFAULT_OPTS="--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"

sd() {
  local depth=${1:-13}
  export FZF_DEFAULT_COMMAND="(echo '..' && $FD_CMD --type d -i -H -d $depth)"
  while true; do
    local dir=$(fzf --preview "tree -C {} -L 1")
    if [ -n "$dir" ]; then
      builtin cd "$dir"
    else
      return
    fi
  done
}

sf() {
  export FZF_DEFAULT_COMMAND="$FD_CMD --type f -i -H -d 13"
  file=$(fzf)
  if [ -n "$file" ]; then
    dir=$(dirname "$file")
    builtin cd "$dir"
  fi
}

cd() {
  if [ "$#" -gt 0 ]; then
    builtin cd "$@"
  else
    sd 1
  fi
}

ff() {
  sf
}

fd() {
  sd
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# On SSH: if not already inside tmux, list active tmux sessions (if any) + hint
if command -v tmux &> /dev/null && [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
  echo
  if tmux has-session 2>/dev/null; then
    echo "Active tmux sessions:"
    tmux list-sessions
    echo
    echo "Hint: attach with  tmux attach -t <session-name>   (or just: tmux attach)"
  else
    echo "No active tmux sessions."
    echo "Hint: start one with  tmux"
  fi
  echo
fi

# Copilot alias with allowed tools
alias copilot="copilot --allow-tool 'shell(git add)' --allow-tool 'shell(git commit)' --allow-tool 'shell(git push)' --allow-tool 'shell(git pull)' --allow-tool 'shell(rm)' --allow-tool write --allow-tool 'shell(rg)' --allow-tool 'shell(fd)' --allow-tool 'shell(grep)' --allow-tool 'shell(xargs)' --allow-tool 'shell(sed)' --allow-tool 'shell(awk)' --allow-tool 'shell(cat)' --allow-tool 'shell(dotnet)' --allow-tool 'shell(git merge-base)' --allow-tool 'shell(jq)' --allow-tool 'shell(git rm)' --allow-tool 'shell(git mv)'"
