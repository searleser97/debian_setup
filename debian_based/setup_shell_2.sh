# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo -e '# ZSH_THEME="amuse"\nZSH_THEME="jonathan"\n\n$(cat ~/.zshrc)' > ~/.zshrc
# Install neovim nightly
sudo snap install --edge nvim --classic
# Install NvChad and neovim dependencies
sudo nala install ripgrep python3-venv xclip
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | zsh # installs NVM (Node Version Manager)
source ~/.zshrc
nvm install node
# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
# Install my NvChad Custom Config
git clone https://github.com/searleser97/NvChadCustomConfig ~/.config/nvim/lua/custom
# Install telegram
pacstall -I telegram-bin
# Install grub-customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer
sudo nala install grub-customizer
# Install input remapper
sudo nala install input-remapper
input-remapper &;disown
# Apply mappings
node ./mappings_setup.cjs
# Install chrome
pacstall -I google-chrome-deb

# reboot to be able to use the new default shell which is ZSH
reboot
