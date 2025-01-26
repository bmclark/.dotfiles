#!/usr/bin/env sh
# This script bootstraps the installation of dotfiles on a new MacOS or Lnux machine.

set -e

check_package() {
    echo "Checking if $1 is installed..."
    if command -v "$1" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

install_package() {
    if check_package "$1"; then
        echo "$1 is already installed."
    else
        echo "Installing $1..."
        brew install "$1"
    fi
}

install_homebrew() {
    if check_package "brew"; then
        echo "Homebrew is already installed."
    else
        echo "Installing Homebrew..."
        /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

main() {
    echo "Bootstrapping packages needed to install dotfiles..."

    install_homebrew
    install_package "git"
    install_package "stow"

    cd ~

    # check if the repository already exists
    if [ -d ~/.dotfiles ]; then
        echo "A  ~/.dotfiles repository already exists..."
        echo "Updating dotfiles repository..."
        cd ~/.dotfiles
        git fetch && git pull
    else
        echo "Cloning dotfiles repository..."
        git clone https://github.com/bmclark/.dotfiles.git ~/.dotfiles
    fi

    echo "Running ~/.dotfiles/scripts/install.sh..."
    cd ~/.dotfiles/scripts
    sh install.sh
}

main