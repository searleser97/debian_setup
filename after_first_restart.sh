#!/bin/zsh
# Complete NVChad installation
xterm -e 'nvim'
# Install oh-my-zsh
xterm -hold -e 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc'
# Remove autostart script
rm ~/.config/autostart/after_first_restart.*
xterm -hold -e 'read -p "[Press ENTER to continue]"'
