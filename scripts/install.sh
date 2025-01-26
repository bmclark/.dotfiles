#!/usr/bin/env sh
# This script installs the dotfiles by symlinking them to the home directory.
# It also installs the necessary dependencies for the dotfiles to work.
# The script is intended to be run on a new machine to set up the dotfiles.

set -e

# Check if a package is installed.
check_package() {
    echo "Checking if $1 is installed..."
    if command -v "$1" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Install a package if it is not already installed.
install_package() {
    if check_package "$1"; then
        echo "$1 is already installed."
    else
        echo "Installing $1..."
        brew install "$1"
    fi
}

# Unpack the dotfiles.
unpack_dotfiles() {
    # move to the dotfiles directory
    cd "$HOME/.dotfiles" || exit 1

    echo "Unpacking dotfiles..."
    stow -t "$HOME" --adopt ansible
    stow -t "$HOME" --adopt bash
    stow -t "$HOME" --adopt emacs
    stow -t "$HOME" --adopt git
    stow -t "$HOME" --adopt ssh
    stow -t "$HOME" --adopt systemd
    stow -t "$HOME" --adopt tmux
    stow -t "$HOME" --adopt vscode
    stow -t "$HOME" --adopt zsh

    # restore in case any were overwritten
    git restore .
}

# Install fonts
setup_fonts() {
    echo "Installing fonts..."
    brew bundle install --file="$HOME/.dotfiles/Brewfile-fonts"

    # reload font cache
    # fc-cache -f -v
}

# Install CLI tools
setup_cli_tools() {
    echo "Installing CLI tools..."
    brew bundle install --file="$HOME/.dotfiles/Brewfile-cli-tools"

}

change_default_shell() {
    # Check if the shell is already set as default for the user
    shell=$(getent passwd "$USER" | awk -F: '{ print $7 }')
    if [ "$shell" = "$(command -v $1)" ]; then
        echo "$1 is already the default shell."
        return
    else
        echo "Changing default shell to $1..."
        sudo usermod --shell "$(command -v $1)" "$USER"
    fi
}   

# Install zsh
setup_zsh() {
    install_package "zsh"
    change_default_shell "zsh"
    install_package "antigen"
}

# Install tmux
setup_tmux() {
    install_package "tmux"
    # install_package "reattach-to-user-namespace"

    # Install tpm
    git submodule init
}

main() {
    echo "Installing packages..."

    unpack_dotfiles

    setup_zsh
    setup_tmux
    setup_fonts
    setup_cli_tools

    echo "Installation complete."
}

main