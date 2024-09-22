ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

if [ "$ISWSL" = "no" ]; then
AUTOSTARTDIR="/etc/xdg/autostart"
fi
# Install git credential manager
dotnet tool install -g git-credential-manager
git-credential-manager configure
# Install common neovim dependencies
nvm install node
sudo nala install ripgrep python3-venv xclip fd-find -y
# Install neovim nightly
brew install neovim --HEAD
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
flatpak install telegram -y

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

# Install oh-my-zsh
echo "After clicking [Enter] this script will proceed to install 'oh-my-zsh' which will"
echo "open up a sub-environment in this terminal, once it does, please type 'exit' and click [Enter]"
echo "so that we return to the main thread and the execution of this script can continue"
echo "click [Enter] to continue"
read A

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
echo "The setup has completed press [Enter] to quit"
read A

if [ "$ISWSL" = "no" ]; then
# Remove autostart script
sudo rm $AUTOSTARTDIR/after_first_restart.*
else
# install win32yank to share clipboard between neovim and windows 11
curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/win32yank.exe
fi
