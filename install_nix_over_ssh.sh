#!/bin/bash

function splash() {
  cat <<'splash'

 _   _ _        _____           _        _ _
| \ | (_)      |_   _|         | |      | | |
|  \| |___  __   | |  _ __  ___| |_ __ _| | | ___ _ __
| . ` | \ \/ /   | | | '_ \/ __| __/ _` | | |/ _ \ '__|
| |\  | |>  <   _| |_| | | \__ \ || (_| | | |  __/ |
|_| \_|_/_/\_\ |_____|_| |_|___/\__\__,_|_|_|\___|_|

splash
}

function green() {
  GREEN='\033[0;32m'
  NC='\033[0m'
  echo -e "${GREEN}$1${NC}"
}

function doInstallNix() {
  green "Downloading Nix installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  if [ "$?" = 1 ]; then
    green "Nix is already installed... Continuing..."
    nix_installed=true
  else
    if [ -d "/nix" ]; then
      nix_installed=true
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
  fi
}

function doInstallHM() {
  if ! command -v home-manager &> /dev/null; then
    green "Installing home-manager..."
    nix profile install nixpkgs#hello
    nix run github:nix-community/home-manager/master -- init
  else
    green "Home-manager is already installed... Continuing..."
  fi
}

function doAppendDirenvToHomeConfig() {
  sed -i '$ d' $HOME/.config/home-manager/home.nix
  tee -a $HOME/.config/home-manager/home.nix <<EOF
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
EOF
}

function doInstallDirenv() {
  if ! nix eval $HOME/.config/home-manager#homeConfigurations.$USER.config.programs.direnv.enable &> /dev/null; then
    doAppendDirenvToHomeConfig
    installing_direnv=true
  else
    green "Direnv is already installed... Skipping..."
  fi
}

function doInstall() {
  splash
  doInstallNix

}

doInstall
