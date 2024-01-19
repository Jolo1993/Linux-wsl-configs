#!/bin/bash
# Init install flags

install_all=false
install_tofu=false
install_nvim=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --all) install_all=true ;;
        --tofu) install_tofu=true ;;
        --nvim) install_nvim=true ;;
        --os)
            if [[ "$2" == "linux" || "$2" == "mac" ]]; then
                OS=$2
                shift #move past argument value
            else
                echo "invalid OS: $2. Options mac or linux"
                exit 1
            fi
            ;;
        *) echo "unknow parameter passed: $1"; exit 1 ;;
    esac
    shift
done
#____________________________________________________Modules________________________________________________________
#_____________________________________________Default folder structur_______________________________________________
fileStructure() {
  mkdir -p $HOME/home_projects/code
      if [ ! -d $HOME/home_projects/code/infra ]; then
          mkdir $HOME/home_projects/code/infra
      else
          echo "Directory already setup"
      fi

      if [ ! -d $HOME/home_projects/code/util ]; then
          mkdir $HOME/home_projects/code/util
      else
          echo "Directory already setup"
      fi

      if [ ! -d $HOME/home_projects/code/programs ]; then
          mkdir $HOME/home_projects/code/programs
      else
          echo "Directory already setup"
      fi
}

#______________________________________________Setup Nvim with pllugin______________________________________________
# Function to check if NeoVim is installed
setup_nvim() {
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
}
#________________________________________________Open Tofu Setup_______________________________________________
setup_tofu(){
# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm install-opentofu.sh

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg


sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg


echo \
  "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | \
  sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null



sudo apt-get update
sudo apt-get install -y tofu
}

#___________________________________________________Modules End_______________________________________________

fileStructure 

# Check if all components should be installed
if [ "$install_all" = true ]; then
   if [ -z "$OS" ]; then
       read -p "Enter OS type for setup (linux/mac): " OS
       if [[ "$OS" != "linux" && "$OS" != "mac" ]]; then
           echo "invalid OS: $OS, Options: mac or linux"
           exit 1
       fi
    fi
    

    setup_nvim "$OS"
    setup_brew
    setup_tofu
    # Set flags for other components as true, and call their functions here
fi

# Individual setup checks
# OpenTofu
if [ "$install_tofu" = true ]; then
    setup_tofu
fi

# nvim
if [[ "$install_nvim" == true && -z "$OS" ]]; then
    echo "You must specify an OS with --os when installing NeoVim with --nvim."
    exit 1
fi

if [[ "$install_nvim" == true ]]; then
    setup_nvim "$OS"
fi

# homebrew
if [ "$install_brew" = true ]; then
    setup_brew
fi



