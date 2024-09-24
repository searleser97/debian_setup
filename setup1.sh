ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi
# Install dotnet tools to be able to install git credential manager after reboot
sudo nala install dotnet-sdk-7.0
# Install node version manager to be able to install nodejs after reboot
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

if [ "$ISWSL" = "no" ]; then
# Install grub-customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo nala install grub-customizer -y
# Install wacom tablet settings gui
sudo nala install kde-config-tablet -y
# Install nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
sudo usermod -aG nordvpn $USER
fi

wezterm start --always-new-process --cwd $(pwd) zsh -c "source setup2.sh"
