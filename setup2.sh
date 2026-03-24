ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

if grep -qi microsoft /proc/version; then
  # Install exfat capabilities
  sudo nala install exfatprogs -y
fi

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

echo "Click [Enter] to continue with the last step"
read A
