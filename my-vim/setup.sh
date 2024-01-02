#!/bin/bash

# Function to check if NeoVim is installed
is_neovim_installed() {
  if command -v nvim >/dev/null 2>&1; then
    return 0 # NeoVim is installed
  else
    return 1 # NeoVim is not installed
  fi
}

# Function to install NeoVim from source
install_neovim_from_source() {
  # Install prerequisites
  if [ "$1" == "linux" ]; then
    sudo apt-get update
    sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
  elif [ "$1" == "mac" ]; then
    brew install ninja libtool automake cmake pkg-config gettext
  fi

  # Clone NeoVim repo and compile
  git clone https://github.com/neovim/neovim.git
  cd neovim
  git checkout stable
  make CMAKE_BUILD_TYPE=Release
  sudo make install

  cd ..
  rm -rf neovim # Optional: remove the cloned directory
}

# Function to configure NeoVim
configure_neovim() {
  PLUGIN_FILE="nvim_plugins.txt"
  if [ ! -f "$PLUGIN_FILE" ]; then
    echo "Plugin file not found: $PLUGIN_FILE"
    exit 1
  fi

  mkdir -p ~/.config/nvim
  echo "call plug#begin('~/.vim/plugged')" > ~/.config/nvim/init.vim
  cat "$PLUGIN_FILE" >> ~/.config/nvim/init.vim
  echo "call plug#end()" >> ~/.config/nvim/init.vim

  # Additional configurations can be added here
  cat <<EOF >> ~/.config/nvim/init.vim
set number
set expandtab
set shiftwidth=4
set tabstop=4
set autoindent
set fileformat=unix

" Language-specific settings
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType yaml setlocal expandtab shiftwidth=2 softtabstop=2
EOF

  # Install vim-plug
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  # Install plugins
  nvim +PlugInstall +qall
}

# Check for OS parameter
if [ "$1" != "linux" ] && [ "$1" != "mac" ]; then
  echo "Usage: $0 [linux|mac]"
  exit 1
fi

# Check if NeoVim is installed
if ! is_neovim_installed; then
  echo "NeoVim is not installed. Installing NeoVim from source."
  install_neovim_from_source $1
else
  echo "NeoVim is already installed."
fi

# Configure NeoVim
configure_neovim

