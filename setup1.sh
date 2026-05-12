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
cargo install git-delta
cargo install cargo-binstall
cargo binstall tree-sitter-cli
# Install git credential manager
dotnet tool install -g git-credential-manager
git-credential-manager configure

# Install mermaid-cli to diagnose issues with syntax related to them in neovim
npm install -g @mermaid-js/mermaid-cli

if [ ! $IS_CODESPACES ]; then
	# set ZShell as default terminal
	chsh -s $(which zsh)
	# sudo chsh "$(id -un)" --shell $(which zsh)
	# az login
else
	sudo chsh -s $(which zsh) $(whoami)
fi

echo "completed setup successfully"
