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
echo -e '# ZSH_THEME="amuse"\nZSH_THEME="jonathan"\n$(cat input)' > input

# Install `brew`
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Install utilities to build stuff
sudo nala install build-essential
# Install neovim nightly
brew install neovim --HEAD
# Install NvChad and neovim dependencies
sudo nala install ripgrep python3-venv xclip
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash # installs NVM
nvm install node
# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
# Install my NvChad Custom Config
git clone https://github.com/searleser97/NvChadCustomConfig ~/.config/nvim/lua/custom

# reboot to be able to use the new default shell which is ZSH
reboot
