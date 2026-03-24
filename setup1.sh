set -e

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
# Install git credential manager
dotnet tool install -g git-credential-manager
git-credential-manager configure
# looks like now, the installation command also asks me to login already
# az login
