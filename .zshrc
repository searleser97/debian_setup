export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="jonathan"

export NVM_DIR="$HOME/.nvm"
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('nvim')

plugins=(git zsh-nvm)
source $ZSH/oh-my-zsh.sh

# Android SDK
export ANDROID=$HOME/Android
export PATH=$ANDROID/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID/platform-tools:$PATH

# Add .NET Core SDK tools
export PATH=$HOME/.dotnet/tools:$PATH
export PATH=$HOME/.dotnet:$PATH
export PATH=$HOME/ProgramFiles/netcoredbg:$PATH
export DOTNET_ROOT=$HOME/.dotnet

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

# Auto-start or attach tmux 'main' session on SSH
if command -v tmux &> /dev/null && [ -n "$SSH_CONNECTION" ]; then
    if [ -z "$TMUX" ]; then
        tmux attach-session -t main || tmux new-session -s main
    fi
fi

# Copilot alias with allowed tools
alias copilot="copilot --allow-tool 'shell(git add)' --allow-tool 'shell(git commit)' --allow-tool 'shell(git push)' --allow-tool 'shell(git pull)' --allow-tool 'shell(rm)' --allow-tool write --allow-tool 'shell(rg)' --allow-tool 'shell(fd)' --allow-tool 'shell(grep)' --allow-tool 'shell(xargs)' --allow-tool 'shell(sed)' --allow-tool 'shell(awk)' --allow-tool 'shell(cat)' --allow-tool 'shell(dotnet)' --allow-tool 'shell(git merge-base)' --allow-tool 'shell(jq)'"
