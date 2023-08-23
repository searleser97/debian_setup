#!/bin/zsh

AUTOSTARTDIR="/etc/xdg/autostart"


# Install VSCode
sudo snap install code --classic
# Install neovim nightly
sudo snap install --edge nvim --classic
# Install common neovim dependencies
sudo nala install ripgrep python3-venv xclip -y
# Install NvChad
# git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
# Install my NvChad Custom Config
# rm -R ~/.config/nvim/lua/custom/
# git clone https://github.com/searleser97/NvChadCustomConfig ~/.config/nvim/lua/custom
# Install telegram
pacstall -I telegram-bin -P
# Add my custom pacstall repo
pacstall -A https://raw.githubusercontent.com/searleser97/pacstall-packages/main
# Install chrome
pacstall -I google-chrome-searleser97 -P

# Install oh-my-zsh
xterm -hold -e bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc' & disown

# Remove autostart script
sudo rm $AUTOSTARTDIR/after_first_restart.*
