ISWSL="no"

if grep -qi microsoft /proc/version; then
  ISWSL="yes"
fi

if [ "$ISWSL" = "no" ]; then
# Remove autostart script
AUTOSTARTDIR="$HOME/.config/autostart"
sudo rm $AUTOSTARTDIR/after_first_restart.*
echo "Setup has completed! Enjoy!"
echo "[Press Enter to Exit]"
read A
fi
