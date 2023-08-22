#!/bin/zsh

AUTOSTARTDIR="/etc/xdg/autostart"

# Install oh-my-zsh
xterm -e zsh -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc' & disown
xterm -hold -e zsh -c 'read -p "[Press ENTER to continue]"'

# setup keyboard mappings
xterm -hold -e zsh -c 'read -p "The following command will open input-remapper UI\nproceed to enter the requested password in the UI and then close the GUI to continue with the execution of this script\n[Press ENTER to continue] && input-remapper-gtk && node /mappings_setup.cjs"'
 # after entering root passwd in the UI, must close the program to continue with script execution


# Remove autostart script
sudo rm $AUTOSTARTDIR/after_first_restart.*
