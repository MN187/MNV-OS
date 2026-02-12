#! /bin/bash

#remove the repository 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#error encounter
set -euo pipefail

# create temporary install list
cat packs/xbps.txt > temp.xbps

# install nvidia drivers if nececarry
echo
echo \#############################################################################################################
echo
read -p "install nvidia drivers? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo nvidia-dkms >> temp.xbps
fi

# update repository + system
sudo xbps-install -Syu

# install xbps packages
sudo xargs -a temp.xbps xbps-install -y

#Install Fonts
sudo curl -L -o /usr/share/fonts/TTF/Hack.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip" && sudo unzip /usr/share/fonts/TTF/Hack.zip -d /usr/share/fonts/TTF && sudo rm /usr/share/fonts/TTF/Hack.zip

# install rsync if not present
sudo xbps-install -y rsync

# apply configs
sudo rsync -cr root/ / -v

# install pipes.sh
git clone https://github.com/pipeseroni/pipes.sh
cd pipes.sh
sudo make install
cd ..
sudo rm -r pipes.sh

# generate locales (Void way)
sudo xbps-reconfigure -f glibc-locales

# change shell to fish (if installed)
if command -v fish >/dev/null 2>&1; then
    chsh -s /usr/bin/fish
fi

# copy Wallpaper
sudo mkdir -p /usr/share/wallpapers
sudo cp wp/cph.gif /usr/share/wallpapers

# apply services (Void = runit)
for service in pipewire pipewire-pulse wireplumber bluetooth ly; do
    if [ -d "/etc/sv/$service" ]; then
        sudo ln -sf /etc/sv/$service /var/service/
    fi
done

# disable tty getty services (Void)
for tty in 1 2 3; do
    sudo rm -f /var/service/agetty-tty$tty 2>/dev/null || true
done

echo
read -p "MNV-OS installed. Reboot now? [y/n] " -n 1 -r
echo

#remove the repository 2
echo "Removing installation repository..."
sudo rm -rf "$SCRIPT_DIR"

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting system..."
    reboot
else
    echo "Installation finished."
    echo "Please reboot the system to start using MNV-OS."
fi
