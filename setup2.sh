ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

# Install exfat capabilities
sudo nala install exfatprogs -y
# Install tmux
sudo nala install tmux -y
# Install git-delta
cargo install git-delta
# Install git credential manager
dotnet tool install -g git-credential-manager
git-credential-manager configure
# Install common neovim dependencies
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install node
sudo nala install ripgrep python3-venv wl-clipboard fd-find -y
# Install neovim nightly
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo nala install neovim -y
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Roslyn lsp server for .NET C# requires more watch instances than the default in linux
echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.conf 
echo "fs.inotify.max_user_watches=1048576" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

if [ "$ISWSL" = "no" ]; then
# Install VSCode
sudo snap install code --classic
code .
# Add desktop entry for VSCode
mkdir ~/.local/share/applications
cp /snap/code/current/meta/gui/code.desktop ~/.local/share/applications/
cp /snap/code/current/meta/gui/code-url-handler.desktop ~/.local/share/applications/
sed -i 's/${SNAP}/\/snap\/code\/current/g' ~/.local/share/applications/code.desktop
sed -i 's/${SNAP}/\/snap\/code\/current/g' ~/.local/share/applications/code-url-handler.desktop
# Install my settings and keybindings in the VSCode installation
cp ~/.config/nvim/settings.json ~/.config/Code/User/settings.json
cp ~/.config/nvim/keybindings.json ~/.config/Code/User/keybindings.json
# Install Microsoft Edge
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo nala update
sudo nala install microsoft-edge-stable -y
# Install telegram
flatpak install app/org.telegram.desktop/x86_64/stable -y
# Install RClone to manage cloud storage services like onedrive or google drive
# sudo nala install rclone
sudo -v ; curl https://rclone.org/install.sh | sudo bash
rclone config
# Install RClone service so that onedrive runs on startup as service
SYSTEMD_DIR=$HOME/.config/systemd/user
mkdir -p $SYSTEMD_DIR
mkdir -p $HOME/OneDrive
cp ./onedrive.service $SYSTEMD_DIR
sed -i "s|\${HOME}|$HOME|g" $SYSTEMD_DIR/onedrive.service
systemctl --user daemon-reload
systemctl --user enable onedrive
# Install DisplayLink Driver to be able to use DisplayLink docks
wget -P "$HOME/Downloads" "https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb"
sudo nala install $HOME/Downloads/synaptics-repository-keyring.deb -y
sudo nala update
sudo nala install displaylink-driver -y
fi

# Install flutter
# sudo nala install openjdk-17-jdk -y
# sudo snap install flutter --classic
# mkdir ~/Android
# the url to get the latest version of command line tools can be found in https://developer.android.com/studio#command-tools
# wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -P ~/Android
# unzip ~/Android/commandlinetools-linux-10406996_latest.zip -d ~/Android/
# mkdir ~/Android/latest/
# mv ~/Android/cmdline-tools/* ~/Android/latest
# mv ~/Android/latest ~/Android/cmdline-tools
# ~/Android/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2" "system-images;android-33;google_apis;x86_64" --sdk_root="$HOME/Android"
# export PATH=$HOME/Android/platform-tools:$PATH
# flutter doctor
# flutter doctor --android-licenses
# flutter doctor

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

echo "Click [Enter] to continue with the last step"
read A
