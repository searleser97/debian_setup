set -e
ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts

# Install Fzf
if [ ! -d "$HOME/.fzf" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --all
fi
# Install git-delta
cargo install git-delta
# Install git credential manager
dotnet tool install -g git-credential-manager
git-credential-manager configure
# looks like now, the installation command also asks me to login already
# az login
if [ "$ISWSL" = "no" ]; then
# Install grub-customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo nala install grub-customizer -y
# Install wacom tablet settings gui
# sudo nala install kde-config-tablet -y
# Install nordvpn
sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh) -p nordvpn-gui
sudo usermod -aG nordvpn $USER
fi
