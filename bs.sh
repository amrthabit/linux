#!/bin/bash

# script must run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root"
  sudo bash "$0" "$@"
  exit
fi

# install packages if not present
packages=("vim" "git" "sudo" "neofetch")
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg"; then
        echo "Installing $pkg..."
        sudo apt-get install -y $pkg
    else
        echo "$pkg is already installed."
    fi
done

# this adds ~/.config/neofetch/config.conf if not present
neofetch

# Add user amr to sudo group
if ! groups amr | grep -q "\bsudo\b"; then
    echo "Adding user amr to sudo group..."
    sudo usermod -aG sudo amr
else
    echo "User amr is already in the sudo group."
fi

# clone and set my linux configs
cd /root
if [ -d "linux" ]; then
    echo "linux configs exist. Checking for updates..."
    git -C linux pull
else
    echo "linux configs not here. Cloning..."
    git clone https://github.com/amrthabit/linux.git
fi
cat linux/root.bashrc > .bashrc
echo "/root/.bashrc updated"
cat linux/.bashrc > /home/amr/.bashrc
echo "/home/amr/.bashrc updated"
cat linux/.config/neofetch/config.conf > /home/amr/.config/neofetch/config.conf
echo "/home/amr/.config/neofetch/config.conf updated"
cat linux/.vimrc > .vimrc
echo "/root/.vimrc updated"
cat linux/.vimrc > /home/amr/.vimrc
echo "/home/amr/.vimrc updated"
chown amr:amr /home/amr/.bashrc /home/amr/.vimrc /home/amr/.config/neofetch/config.conf

sudo -u amr bash <<EOF

# set git config
git config --global user.name "Amr Thabit"
git config --global user.email amrthabi7@gmail.com
cd /home/amr/linux
git remote set-url origin git@github.com:amrthabit/linux.git

# generate ssh keys
if ! [ -e ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
fi
cat ~/.ssh/id_ed25519.pub

EOF
