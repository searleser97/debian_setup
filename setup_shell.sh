# Install FiraCode Nerd Font
mkdir -p ~/.fonts/f 
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraMono.zip -P ~/.fonts/f
unzip ~/.fonts/f/FiraMono.zip -d ~/.fonts/f/
# Install pacstall
sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
# Install nala
pacstall -I nala-deb -P
# Install ZSHell
sudo nala install zsh -y
chsh -s $(which zsh)
echo '# remove this comment' > ~/.zshrc
# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo -e "# ZSH_THEME=\"amuse\"\nZSH_THEME=\"jonathan\"\n\n$(cat ~/.zshrc)" > ~/.zshrc
# Install nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash # installs NVM (Node Version Manager)
source ./my_bashrc
cat ./my_bashrc >> ~/.zshrc
nvm install node
# Install neovim nightly
sudo snap install --edge nvim --classic
# Install NvChad and neovim dependencies
sudo nala install ripgrep python3-venv xclip -y
# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
# Install my NvChad Custom Config
git clone https://github.com/searleser97/NvChadCustomConfig ~/.config/nvim/lua/custom
# Install grub-customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer
sudo nala install grub-customizer -y
# Install touchpad drivers
sudo nala install xserver-xorg-input-synaptics
# Install input remapper
sudo nala install input-remapper -y
echo "The following command will open input-remapper UI"
echo "proceed to enter the requested password in the UI and then close the GUI to continue with the execution of this script"
read -p "[Press ENTER to continue]"
input-remapper-gtk # after entering root passwd in the UI, must close the program to continue with script execution
# Apply mappings
node ./mappings_setup.cjs
# Add my custom pacstall repo
pacstall -A https://raw.githubusercontent.com/searleser97/pacstall-packages/main
# Install chrome
pacstall -I google-chrome-searleser97 -P
# Install telegram
pacstall -I telegram-bin -P
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

# reboot to be able to use the new default shell which is ZSH and for nordvpn to work properly
reboot

