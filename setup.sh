ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

# Install my zshrc config
cat ./.zshrc > ~/.zshrc
# Install my neovim config
git clone https://github.com/searleser97/nvim_lua ~/.config/nvim
# Install my wezterm settings
cp ~/.config/nvim/.wezterm.config ~/.wezterm.config
# Install my gitconfig settings
cp ~/.config/nvim/.gitconfig ~/.gitconfig
# Install pacstall
sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
# Install nala
pacstall -I nala-deb -P
# Install Wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo nala update
sudo nala install wezterm -y
# Install ZSHell
sudo nala install zsh -y
# set ZShell as default terminal
chsh -s $(which zsh)
# Install dotnet tools to be able to install git credential manager after reboot
sudo nala install dotnet-sdk-7.0
# Install node version manager to be able to install nodejs after reboot
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
if [ "$ISWSL" = "no" ]; then
# Install grub-customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo nala install grub-customizer -y
# Install wacom tablet settings gui
sudo nala install kde-config-tablet -y
# Install nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER

# Install FiraCode Nerd Font (not neede anymore since wezterm supports nerdfont chars already
# mkdir -p ~/.fonts/f 
# wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraMono.zip -P ~/.fonts/f
# unzip ~/.fonts/f/FiraMono.zip -d ~/.fonts/f/

# setup first restart script
AUTOSTARTDIR="/etc/xdg/autostart"
echo "creating temporary autostart file in $AUTOSTARTDIR"
sudo mkdir $AUTOSTARTDIR
sudo cp after_first_restart.desktop $AUTOSTARTDIR
chmod +x ./after_first_restart.sh
echo "Exec=wezterm start zsh -c \"cd $(pwd) && source ./after_first_restart.sh; zsh -i'\" | sudo tee -a $AUTOSTARTDIR/after_first_restart.desktop

echo "The stage 1 of the setup has completed !"
echo "Click [Enter] to reboot your machine and continue with the final stage of the setup"
read A

# reboot to be able to use the new default shell which is ZSH and for nordvpn to work properly
reboot
fi


