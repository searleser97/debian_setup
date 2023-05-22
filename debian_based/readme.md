# Steps to setup a Debian Based Distro

## 1. Install Chrome

Chrome already published a ".deb" package in its website so we just need to go to https://www.google.com/chrome/ and intiutively follow the steps to get it installed.

## 2. Install Nala package manager

Nala is a nice package manager, way better than "apt-get" build on top of "apt".

1. Go to https://gitlab.com/volian/volian-archive/-/releases
2. Download and install the file called volian-archive-keyring_x.x.x_all.deb
3. Download and install the file called volian-archive-nala_x.x.x_all.deb
4. Verify Installation by running `nala` in your terminal

For more information about **nala** visit https://gitlab.com/volian/nala

## 3. Setup Palm Detection in touchpad

This to avoid wrongly clicking stuff while typing on your keyboard

1. Run `sudo nala install xserver-xorg-input-synaptics`
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

1. Run `sudo nala install input-remapper`
2. Search for "Input Remapper" app in you app launcher menu and open it
3. Open the app and configure the key mappings like in the following images

<table>
<tr>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/328371ad-627e-4646-8663-7c3ca2e0d465" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/2870bcaa-6854-459b-afbd-98822fe07d8b" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/544ee27f-bdc1-4286-850f-94b1da6f8b92" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/bebcdb91-ea4f-4959-95a2-651de3100a66" /></td>
<td><img src="https://github.com/searleser97/linux_setup/assets/5056411/72cff501-630a-45fc-a7a9-051a4981b1e6" /></td>
</tr>
</table>

