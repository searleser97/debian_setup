# Install nala
curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
sudo apt install -t nala nala

sudo chsh "$(id -un)" --shell $(which zsh)

export RUNZSH="no"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
# Install my zshrc config
cat ./.zshrc > ~/.zshrc
# Install tmux config
cat ./.tmux.conf > ~/.tmux.conf
# Install zsh-nvm to load nvm lazily (more details in the .zshrc file)
mkdir -p ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
# Install my neovim config
git clone https://github.com/searleser97/nvim_lua ~/.config/nvim
mkdir ~/.local/share/nvim/sessions
# Install my gitconfig settings
cp ~/.config/nvim/.gitconfig ~/.gitconfig
# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
cargo install git-delta
sudo nala install ripgrep python3-venv wl-clipboard fd-find -y
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo nala install neovim -y
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
# Roslyn lsp server for .NET C# requires more watch instances than the default in linux
echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.conf 
echo "fs.inotify.max_user_watches=1048576" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo nala install tmux -y
