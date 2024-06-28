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

function doInstallHM() {
  if ! command -v home-manager &> /dev/null; then
    nix profile install nixpkgs#hello
    green "Installing home-manager..."
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
  if [ "$(nix eval $HOME/.config/home-manager#homeConfigurations.$USER.config.programs.direnv.enable)" == "false" ]; then
    green "Appending direnv to home.nix..."
    doAppendDirenvToHomeConfig
    installing_direnv=true
  else
    green "Direnv is already installed... Skipping..."
  fi
}

function doInstall() {
  splash

  nix_installed=false
  # Check if Nix is installed:
  if ! command -v nix &> /dev/null; then
    green "Nix is not installed... Exitting..."
    exit 1
  else
    nix_installed=true
  fi

  if [[ $nix_installed = true ]]; then
    doInstallHM
    doInstallDirenv
    nix run github:nix-community/home-manager/master -- switch
    green "Direnv has been installed"
  fi
}

doInstall
