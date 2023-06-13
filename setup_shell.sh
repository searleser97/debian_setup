# Install FiraCode Nerd Font
mkdir -p ~/.fonts/f 
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraMono.zip -P ~/.fonts/f
unzip ~/.fonts/f/FiraMono.zip -d ~/.fonts/f/
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
# Install neovim nightly
sudo snap install --edge nvim --classic
# Install NvChad and neovim dependencies
sudo nala install ripgrep python3-venv xclip -y
# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
# Install my NvChad Custom Config
rm -R ~/.config/nvim/lua/custom/
git clone https://github.com/searleser97/NvChadCustomConfig ~/.config/nvim/lua/custom
# Install grub-customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo nala install grub-customizer -y
# Install touchpad drivers
sudo nala install xserver-xorg-input-synaptics -y
# Install telegram
pacstall -I telegram-bin -P
# Add my custom pacstall repo
pacstall -A https://raw.githubusercontent.com/searleser97/pacstall-packages/main
# Install chrome
pacstall -I google-chrome-searleser97 -P
# Install nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER

# Install wine
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
sudo apt update
sudo apt install libpoppler-glib8:{i386,amd64}=22.02.0-2ubuntu0.1
sudo nala install --install-recommends winehq-stable
winecfg

set AUTOSTARTDIR="/etc/xdg/autostart"
echo "creating temporary autostart file in $AUTOSTARTDIR"
sudo mkdir $AUTOSTARTDIR
cp after_first_restart.desktop 
chmod +x $(AUTOSTARTDIR)/after_first_restart.desktop
chmod +x ./after_first_restart.sh

echo "Exec=xterm -e 'source $(pwd)/after_first_restart.sh'" >> $(AUTOSTARTDIR)/after_first_restart.desktop

# Install input remapper
sudo nala install input-remapper -y
echo "The following command will open input-remapper UI"
echo "proceed to enter the requested password in the UI and then close the GUI to continue with the execution of this script"
read -p "[Press ENTER to continue]"
input-remapper-gtk # after entering root passwd in the UI, must close the program to continue with script execution
# Apply mappings
node ./mappings_setup.cjs

cat ./my_zshrc > ~/.zshrc
# reboot to be able to use the new default shell which is ZSH and for nordvpn to work properly
reboot

