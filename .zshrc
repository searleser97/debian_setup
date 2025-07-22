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

fd() {
  export FZF_DEFAULT_COMMAND='fdfind --type d -i -H -d 13'
  dir=$(fzf)
  if [ -n "$dir" ]; then
    cd "$dir"
  fi
}

ff() {
  export FZF_DEFAULT_COMMAND='fdfind --type f -i -H -d 13'
  file=$(fzf)
  if [ -n "$file" ]; then
    dir=$(dirname "$file")
    cd "$dir"
  fi
}

cd() {
  if [ "$#" -gt 0 ]; then
    builtin cd "$@"
  else
    export FZF_DEFAULT_COMMAND='fdfind --type d -i -H -d 1'
    dir=$(fzf)
    if [ -n "$dir" ]; then
      builtin cd "$dir"
    fi
  fi
}


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Auto-start or attach tmux 'main' session on SSH
if command -v tmux &> /dev/null && [ -n "$SSH_CONNECTION" ]; then
    if [ -z "$TMUX" ]; then
        exec tmux attach-session -t main || exec tmux new-session -s main
    fi
fi






