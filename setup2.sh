ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

# Install git credential manager
dotnet tool install -g git-credential-manager
git-credential-manager configure
# Install common neovim dependencies
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install node
sudo nala install ripgrep python3-venv xclip fd-find -y
# Install neovim nightly
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo nala install neovim -y
if [ "$ISWSL" = "no" ]; then
# Install VSCode
sudo snap install code --classic
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
curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/win32yank.exe
fi
