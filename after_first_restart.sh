#!/bin/zsh
# Install oh-my-zsh
xterm -e zsh -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc' & disown
xterm -hold -e zsh -c 'read -p "[Press ENTER to continue]"'
# Remove autostart script
AUTOSTARTDIR="/etc/xdg/autostart"
sudo rm $AUTOSTARTDIR/after_first_restart.*
