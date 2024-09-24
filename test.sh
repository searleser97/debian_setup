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
