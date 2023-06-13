#!/bin/bash
# Complete NVChad installation
xterm -e 'nvim' & disown
# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
# Remove autostart script
rm ~/.config/autostart/after_first_restart.*
read -p "[Press ENTER to continue]"
