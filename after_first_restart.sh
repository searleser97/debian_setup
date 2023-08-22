#!/bin/zsh

AUTOSTARTDIR="/etc/xdg/autostart"

# Remove autostart script
sudo rm $AUTOSTARTDIR/after_first_restart.*

# Install oh-my-zsh
xterm -e bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc' & disown

# setup keyboard mappings
node ./mappings_setup.cjs
input-remapper-gtk
