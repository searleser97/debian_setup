source ~/.zshrc
nvm install node
# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
# Install my NvChad Custom Config
git clone https://github.com/searleser97/NvChadCustomConfig ~/.config/nvim/lua/custom
# Install telegram
pacstall -I telegram-bin
# Install grub-customizer
sudo nala install grub-customizer
# Install input remapper
sudo nala install input-remapper
# Apply mappings
node ./mappings_setup.cjs
# Install chrome
pacstall -I google-chrome-deb

# reboot to be able to use the new default shell which is ZSH
reboot
