# Steps to setup a Debian Based Distro

## Setup Shell Environment

1. Download the `setup_shell.sh` file from this folder
2. Run `sh setup_shell.sh`

Note: The command above will:
- Install FiraCode Mono Nerd Font (must setup in terminal app afterwards)
- Install pacstall package manager (The AUR version of debian-based distros)
- Install nala package manager for debian based distros
- Install ZSH shell and make it default in the next boot
- Install neovim-nightly with NvChad config
- Install telegram (execute it for first time from terminal with the `telegram` command)
- Install grub-customizer (to re-order boot entries)
- Install input-remapper and attemps to setup my mappings config (to remap keyboard keys)
- Install chrome

## Setup Palm Detection in touchpad

This to avoid wrongly clicking stuff while typing on your keyboard

1. Run `sudo nala install xserver-xorg-input-synaptics` (The `setup_shell.sh` file already installs it)
2. Reboot your machine so that the new drivers load
3. Adjust touchpad settings with the system settings GUI

<table>
<tr><td colspan="2">KDE Neon Settings GUI Screenshots</td></tr>
<tr>
<td>
<img src="https://github.com/searleser97/linux_setup/assets/5056411/41765a5b-c2d6-4300-8080-4dd78dc3563d" />
</td>
<td>
<img src="https://github.com/searleser97/linux_setup/assets/5056411/b5f78820-babb-46ce-b8d5-feb568ac0fa9" />
</td>
</table>

## Remap keyboard keys

There is already a GUI utility that helps us with this task called `input-remapper`
The `setup_shell.sh` file attempts to execute the following steps programmatically, but it fails you can do it manually as follows.

1. Run `sudo nala install input-remapper` (The `setup_shell.sh` file already installs it)
2. Search for "Input Remapper" app in you app launcher menu and open it
3. Open the app and configure the key mappings like in the following images

<table>
<tr>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/328371ad-627e-4646-8663-7c3ca2e0d465" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/2870bcaa-6854-459b-afbd-98822fe07d8b" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/544ee27f-bdc1-4286-850f-94b1da6f8b92" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/bebcdb91-ea4f-4959-95a2-651de3100a66" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/72cff501-630a-45fc-a7a9-051a4981b1e6" /></td>
  <td><img src="https://github.com/searleser97/linux_setup/assets/5056411/25ffe456-825e-49ea-bc80-721b3b5da875" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/7e9d2e79-9f9f-4260-8caa-79b9f6522133" /></td>
</tr>
</table>

## Connect bluetooth headphones

1. Make sure that your PC's bluetooth is visible to others
<table>
  <tr>
    <th>1</th><th>2</th>
  </tr>
<tr>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/4326a48a-bfd7-4372-bfff-8bf78e27d243" /></td>
  <td><img src="https://github.com/searleser97/linux_setup/assets/5056411/e7e1f63b-26d9-4ee0-9551-ea058dc994cf" /></td>
</tr>
</table>

2. Follow usual steps to pair a new device (Click add new device, put your device in pairing mode, ...)
