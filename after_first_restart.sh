#!/bin/zsh

AUTOSTARTDIR="/etc/xdg/autostart"

# Ensure key mappings are applied
echo "After clicking [Enter Key] the 'input-remapper' app will be executed"
echo "You will see that 'my_mappings' config will be preselected just click on the 'apply' button"
echo "to ensure the mappings are applied to your system"
read -p "Click [Enter] to continue"
input-remapper-gtk

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
echo "After clicking [Enter] this script will proceed to install 'oh-my-zsh' which will"
echo "open up a sub-environment in this terminal, once it does, please type 'exit' and click [Enter]"
echo "so that we return to the main thread and the execution of this script can continue"
read -p "click [Enter] to continue"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
read -p "The setup has completed press [Enter] to quit"

# Remove autostart script
sudo rm $AUTOSTARTDIR/after_first_restart.*
