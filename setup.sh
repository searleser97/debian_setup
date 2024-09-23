ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi
# Install pacstall
sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
# Install nala
pacstall -I nala-deb -P
# Install ZSHell
sudo nala install zsh -y
# set ZShell as default terminal
chsh -s $(which zsh)
# Install Oh-My-ZSH
export RUNZSH="no"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" 
# Install my zshrc config
sed -i 's/ZSH_THEME=.*$/ZSH_THEME="jonathan"/' ~/.zshrc
cat ./.zshrc >> ~/.zshrc
# Install Wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo nala update
sudo nala install wezterm -y
# Install my neovim config
git clone https://github.com/searleser97/nvim_lua ~/.config/nvim
# Install my wezterm settings
cp ~/.config/nvim/.wezterm.lua ~/.wezterm.lua
# Install my gitconfig settings
cp ~/.config/nvim/.gitconfig ~/.gitconfig
wezterm start --always-new-process --cwd $(pwd) zsh -c "source setup1.sh"
if [ "$ISWSL" = "no" ]; then
# setup first restart script
AUTOSTARTDIR="$HOME/.config/autostart"
echo "creating temporary autostart file in $AUTOSTARTDIR"
sudo mkdir $AUTOSTARTDIR
DESKTOPFILE="$AUTOSTARTDIR/after_first_restart.desktop"
sudo touch $DESKTOPFILE

echo "[Desktop Entry]" | sudo tee $DESKTOPFILE
echo "Type=Application" | sudo tee -a $DESKTOPFILE
echo "Name=After First Restart Script" | sudo tee -a $DESKTOPFILE
echo "Exec=/usr/bin/wezterm start --cwd $(pwd) /usr/bin/zsh -c \"source ./after_first_restart.sh; zsh -i\"" | sudo tee -a $DESKTOPFILE
sudo chmod +x $DESKTOPFILE
echo "The stage 1 of the setup has completed !"
echo "Click [Enter] to reboot your machine and continue with the final stage of the setup"
read A

# reboot to be able to use the new default shell which is ZSH and for nordvpn to work properly
reboot
fi


