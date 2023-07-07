#!/bin/bash
set -x
set -euo pipefail

cd ~

echo "************ Installing rustup"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
sh rustup.sh --default-toolchain nightly --profile minimal -y
rm rustup.sh

# echo "************ Installing clippy"

# bash -c "rustup component add clippy"

echo "************ Upgrading the system and installing system dependencies"

sudo apt update
sudo apt install -y build-essential || echo "build-essential already installed"
sudo apt install -y lld || echo "lld already installed"
sudo apt install -y pkg-config libssl-dev || echo "pkg-config libssl-dev already installed"

echo "************ Installing npm"

sudo apt install -y npm || echo "npm already installed"

echo "************ Installing typescript"
sudo npm install -g typescript@latest
