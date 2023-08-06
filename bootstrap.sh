#!/bin/sh

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

# Install pip3 if it doesn't exist
install_pip3() {
    if ! command -v pip3 > /dev/null 2>&1; then
        echo "pip3 not found. Installing..."
        case "$DISTRO" in
            "ubuntu"|"debian")
                sudo apt-get update
                sudo apt-get install -y python3-pip git
                ;;
            "opensuse")
                sudo zypper install -y python3-pip git
                ;;
            "fedora"|"rhel")
                sudo dnf install -y python3-pip git
                ;;
            *)
                echo "Unsupported distribution: $DISTRO"
                exit 1
                ;;
        esac
    fi
}

# Install Ansible via pip
install_ansible() {
    if ! command -v pip3 > /dev/null 2>&1; then
        echo "Ansible not found. Installing..."
        pip3 install --user ansible
    fi
}

# Main function
main() {
    detect_distro
    install_pip3
    install_ansible
}

main

echo "Dependency installation complete."
echo "Installing dotfiles"
ansible-pull -U https://git.bclark.net/bryan/ansible-bootstrap.git main.yml