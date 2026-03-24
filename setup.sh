ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

# libatomic1 is required for nodejs
# libicu-dev is required for dotnet git credential manager
sudo apt install curl wget git libatomic1 build-essential libicu-dev
# Install pacstall (pacstall was mainly needed before for nala, but now is not the case)
# sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"
# Install nala
#curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
#sudo apt install -t nala nala
sudo apt install nala
# Install ZSHell
sudo nala install zsh -y
# set ZShell as default terminal
chsh -s $(which zsh)
sudo chsh "$(id -un)" --shell $(which zsh)
# Install Oh-My-ZSH
export RUNZSH="no"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
# Install my zshrc config
cat ./.zshrc > ~/.zshrc
# Install tmux config
cat ./.tmux.conf > ~/.tmux.conf
# Install zsh-nvm to load nvm lazily (more details in the .zshrc file)
mkdir -p ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
if [ "$ISWSL" = "no" ]; then
# Install Wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo nala update
sudo nala install wezterm -y
# Install my wezterm settings
cp ~/.config/nvim/.wezterm.lua ~/.wezterm.lua
fi
# Install my neovim config
git clone https://github.com/searleser97/nvim_lua ~/.config/nvim
mkdir -p ~/.local/share/nvim/sessions
# Install my gitconfig settings
cp ~/.config/nvim/.gitconfig ~/.gitconfig

if [ "$ISWSL" = "no" ]; then
wezterm start --always-new-process --cwd $(pwd) zsh -c "source setup1.sh"
# setup first restart script
AUTOSTARTDIR="$HOME/.config/autostart"
DESKTOPFILE="$AUTOSTARTDIR/after_first_restart.desktop"
echo "creating temporary autostart file in $AUTOSTARTDIR"
sudo mkdir $AUTOSTARTDIR
sudo cp ./after_first_restart.desktop $AUTOSTARTDIR
sudo sed -i "s|\${cwd}|$(pwd)|g" $DESKTOPFILE
sudo chmod +x $DESKTOPFILE
echo "The stage 1 of the setup has completed !"
echo "Click [Enter] to reboot your machine and continue with the final stage of the setup"
read A

# reboot to be able to use the new default shell which is ZSH and for nordvpn to work properly
reboot
fi


