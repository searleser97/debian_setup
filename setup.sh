ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

# Install my gitconfig settings
cp ~/.config/nvim/.gitconfig ~/.gitconfig

sudo apt update
# Install nala
#curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
#sudo apt install -t nala nala
sudo apt install nala -y
# libatomic1 is required for nodejs
# libicu-dev is required for dotnet git credential manager
sudo nala install zsh curl wget git libatomic1 build-essential libicu-dev tmux ripgrep python3-venv fd-find unzip -y
# Install/Update neovim nightly
mkdir -p ~/.local/bin && curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage -o ~/.local/bin/nvim && chmod +x ~/.local/bin/nvim

# Install pacstall (pacstall was mainly needed before for nala, but now is not the case)
# sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install || wget -q https://pacstall.dev/q/install -O -)"

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Install git-delta
cargo install git-delta
# Roslyn lsp server for .NET C# requires more watch instances than the default in linux
echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.conf 
echo "fs.inotify.max_user_watches=1048576" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
# Install tmux config
cat ./.tmux.conf > ~/.tmux.conf
# Install my neovim config
git clone https://github.com/searleser97/nvim_lua ~/.config/nvim
mkdir -p ~/.local/share/nvim/sessions
# install github cli
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
# install copilot cli
curl -fsSL https://gh.io/copilot-install | bash
# install claude code cli
curl -fsSL https://claude.ai/install.sh | bash
# Configure Claude Code settings
mkdir -p ~/.claude
cp ./claude-settings.json ~/.claude/settings.json
# Install Fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
# Install dotnet tools to be able to install git credential manager after reboot
mkdir -p ~/.dotnet/
wget https://dot.net/v1/dotnet-install.sh -O ~/.dotnet/dotnet-install.sh
chmod +x ~/.dotnet/dotnet-install.sh
~/.dotnet/dotnet-install.sh --channel 8.0
~/.dotnet/dotnet-install.sh --channel 9.0
# Install git credential manager
~/.dotnet/dotnet tool install -g git-credential-manager
if [ "$ISWSL" = "yes" ]; then
# install win32yank to share clipboard between neovim and windows 11
curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/win32yank.exe

# to be able to restore (install dependencies) dotnet solutions (projects)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
wget -qO- https://aka.ms/install-artifacts-credprovider.sh | bash
az login
fi
# Install my zshrc config
cat ./.zshrc > ~/.zshrc
# Install zsh-nvm to load nvm lazily (more details in the .zshrc file)
mkdir -p ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
# Install Oh-My-ZSH
export RUNZSH="no"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc -y
# set ZShell as default terminal
chsh -s $(which zsh)
sudo chsh "$(id -un)" --shell $(which zsh)

git-credential-manager configure
if [ "$ISWSL" = "no" ]; then
# Install Wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo nala update
sudo nala install wezterm -y
# Install my wezterm settings
cp ~/.config/nvim/.wezterm.lua ~/.wezterm.lua

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


