#!/bin/bash

# Function to detect the distro
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo "Cannot identify the distribution."
        exit 1
    fi
}

# Install function for Debian and Ubuntu
install_debian_ubuntu() {
    sudo apt-get update
    sudo apt-get install -y stow
}

# Install function for Red Hat and Fedora
install_redhat_fedora() {
    sudo dnf install -y stow
}

if ! command -v stow &> /dev/null
then
    echo "GNU stow could not be found. Installing..."
    # Detect the distribution
    detect_distro

    # Choose the install function based on the detected distribution
    case "$DISTRO" in
        "ubuntu"|"debian")
            install_debian_ubuntu
            ;;
        "rhel"|"fedora")
            install_redhat_fedora
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
fi


echo "GNU Stow installation complete."
echo "Installing dotfiles"
stow .
