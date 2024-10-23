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
# Set git credential manager store mode
export GCM_CREDENTIAL_STORE=cache





