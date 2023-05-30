# Install FiraCode Nerd Font
mkdir -p ~/.fonts/f 
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraMono.zip -P ~/.fonts/f
unzip ~/.fonts/f/FiraMono.zip -d ~/.fonts/f/
# Install pacstall
sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
# Install nala
pacstall -I nala-deb
# Install ZSHell
sudo nala install zsh
chsh -s $(which zsh)
zsh
# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo -e '# ZSH_THEME="amuse"\nZSH_THEME="jonathan"\n\n$(cat ~/.zshrc)' > ~/.zshrc
# Install neovim nightly
sudo snap install --edge nvim --classic
# Install NvChad and neovim dependencies
sudo nala install ripgrep python3-venv xclip
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | zsh # installs NVM (Node Version Manager)
sh ./setup_shell_2.sh | zsh
