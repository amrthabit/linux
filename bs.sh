#!/bin/bash

packages=("vim" "git" "sudo" "neofetch")

for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $pkg"; then
        echo "Installing $pkg..."
        sudo apt-get install -y $pkg
    else
        echo "$pkg is already installed."
    fi
done

# Add user amr to sudo group
if ! groups amr | grep -q "\bsudo\b"; then
    echo "Adding user amr to sudo group..."
    sudo usermod -aG sudo amr
else
    echo "User amr is already in the sudo group."
fi

# clone and set my linux configs
copy_files() {
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
}

cd /root

if [ -d "linux" ]; then
    echo "linux configs exist. Checking for updates..."
    if git -C linux pull | grep -q 'Already up to date'; then
        echo "Already up to date, no changes pulled."
    else
        copy_files
    fi
else
    echo "linux configs not here. Cloning..."
    git clone https://github.com/amrthabit/linux.git
    copy_files
fi
