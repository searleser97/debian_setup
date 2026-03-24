# Debian Setup Repository

This repository contains configuration files and setup scripts for a Debian development environment.

# If installing in wsl
Please first ensure that Global Secure Access Client is uninstalled, this can only be done through the control panel in the old way.

And ensure that the .wslconfig file is already copied from this repository to the windows $HOME directory.

# Command to run initially

```bash
cd ~ && sudo apt update && sudo apt install git -y && git clone https://github.com/searleser97/debian_setup && cd debian_setup && sh setup.sh
```
