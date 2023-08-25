ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

# Install pacstall
sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
# Install nala
pacstall -I nala-deb -P
# Install xterm
sudo nala install xterm -y
# Install ZSHell
sudo nala install zsh -y
chsh -s $(which zsh)
# Install nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash # installs NVM (Node Version Manager)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node

if [ "$ISWSL" = "no" ]; then


# Install grub-customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo nala install grub-customizer -y
# Install touchpad drivers
sudo nala install xserver-xorg-input-synaptics -y
# Install wacom tablet settings gui
sudo nala install kde-config-tablet -y
# Install nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER
# Install input remapper
sudo nala install input-remapper -y

# setup keyboard mappings
echo "After clicking [Enter Key] in this terminal you will be prompted to input your root password to open the 'input-remapper' app"
echo "proceed to do so and then close the 'input-remapper' app to continue with the execution of this script"
echo "Click [Enter] to continue"
read A

input-remapper-gtk
node ./mappings_setup.cjs

# Install FiraCode Nerd Font
mkdir -p ~/.fonts/f 
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraMono.zip -P ~/.fonts/f
unzip ~/.fonts/f/FiraMono.zip -d ~/.fonts/f/

# setup first restart script
AUTOSTARTDIR="/etc/xdg/autostart"
echo "creating temporary autostart file in $AUTOSTARTDIR"
sudo mkdir $AUTOSTARTDIR
sudo cp after_first_restart.desktop $AUTOSTARTDIR
chmod +x ./after_first_restart.sh
echo "Exec=xterm -e bash -c 'cd $(pwd) && source ./after_first_restart.sh' &" | sudo tee -a $AUTOSTARTDIR/after_first_restart.desktop

echo "The stage 1 of the setup has completed !"
echo "Click [Enter] to reboot your machine and continue with the final stage of the setup"
read A

# reboot to be able to use the new default shell which is ZSH and for nordvpn to work properly
reboot
fi

cat ./my_zshrc > ~/.zshrc
