set -e

IS_CODESPACES=false
if [[ "${CODESPACES:-}" == "true" || -n "${CODESPACE_NAME:-}" ]]; then
  IS_CODESPACES=true
fi

export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts

# Install Fzf
if [ ! -d "$HOME/.fzf" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --all
fi
# Install git-delta
$HOME/.cargo/bin/cargo install git-delta
$HOME/.cargo/bin/cargo install cargo-binstall
$HOME/.cargo/bin/cargo binstall tree-sitter-cli
# Install git credential manager
$HOME/.dotnet/dotnet tool install -g git-credential-manager
$HOME/.dotnet/tools/git-credential-manager configure

pip install termaid

if [ $IS_CODESPACES = "false" ]; then
	# set ZShell as default terminal
	chsh -s $(which zsh)
	# sudo chsh "$(id -un)" --shell $(which zsh)
	# az login
else
	sudo chsh -s $(which zsh) $(whoami)
fi

echo "completed setup successfully"
