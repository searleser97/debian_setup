ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

if [ "$ISWSL" = "no" ]; then
AUTOSTARTDIR="/etc/xdg/autostart"

# Ensure key mappings are applied
echo "After clicking [Enter Key] the 'input-remapper' app will be executed"
echo "You will see that 'my_mappings' config will be preselected just click on the 'apply' button"
echo "to ensure the mappings are applied to your system"
echo "Click [Enter] to continue"
read A
input-remapper-gtk
fi

# Install VSCode
sudo snap install code --classic
# Install neovim nightly
sudo snap install --edge nvim --classic
# Install common neovim dependencies
sudo nala install ripgrep python3-venv xclip fd-find -y
# Install my neovim config
git clone https://github.com/searleser97/nvim_lua ~/.config/nvim
# Install telegram
pacstall -I telegram-bin -P
# Add my custom pacstall repo
pacstall -A https://raw.githubusercontent.com/searleser97/pacstall-packages/main
# Install chrome
pacstall -I google-chrome-searleser97 -P

# save git credentials in computer
git config --global credential.helper store

# Add desktop entry for VSCode
mkdir ~/.local/share/applications
cp /snap/code/current/meta/gui/code.desktop ~/.local/share/applications/
cp /snap/code/current/meta/gui/code-url-handler.desktop ~/.local/share/applications/
sed -i 's/${SNAP}/\/snap\/code\/current/g' ~/.local/share/applications/code.desktop
sed -i 's/${SNAP}/\/snap\/code\/current/g' ~/.local/share/applications/code-url-handler.desktop

# Install flutter
sudo nala install openjdk-17-jdk -y
sudo snap install flutter --classic
mkdir ~/Android
# the url to get the latest version of command line tools can be found in https://developer.android.com/studio#command-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -P ~/Android
unzip ~/Android/commandlinetools-linux-10406996_latest.zip -d ~/Android/
mkdir ~/Android/latest/
mv ~/Android/cmdline-tools/* ~/Android/latest
mv ~/Android/latest ~/Android/cmdline-tools
~/Android/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2" "system-images;android-33;google_apis;x86_64" --sdk_root="$HOME/Android"
export PATH=$HOME/Android/platform-tools:$PATH
flutter doctor --android-licenses
flutter doctor


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
