#!/bin/bash

EMAIL="a.pliutau@gmail.com"

function install {
	cp -a ./.zshrc $HOME/
  	cp -a ./.env $HOME/
    cp -a ./.yabairc $HOME/
    cp -aR ./.config $HOME/

    # install ohmyzsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # install nerdfont
    curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
    ~/.local/bin/getnf -i GeistMono

    # install homebrew
    if [[ $(command -v brew) == "" ]]; then
        echo "Installing Hombrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Updating Homebrew"
        brew update
    fi

    # install homebrew packages
    echo "Installing Homebrew packages"
    brew install golang protobuf kubectl neovim koekeishiya/formulae/yabai
    brew install --cask chromium
    brew install --cask google-cloud-sdk
    gcloud components install gke-gcloud-auth-plugin

    # install dev tools
    go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

    # start yabai
    # yabai --start-service

    # install simple-bar, install Übersicht first - https://tracesof.net/uebersicht/
    mkdir -p $HOME/code/widgets
    if [ -d "$HOME/code/widgets/simple-bar" ]
    then
        echo "Updating simple-bar"
   		cd ~/code/widgets/simple-bar
    	git fetch
     	git pull
    else
        echo "Installing simple-bar"
    	git clone https://github.com/Jean-Tinland/simple-bar ~/code/widgets/simple-bar
    fi

    if [ ! -f "$HOME/.ssh/id_ed25519" ]
    then
        echo "Generating ssh key"
        ssh-keygen -t ed25519 -N "" -C "$EMAIL" -f $HOME/.ssh/id_ed25519
    fi

    echo "Configuring git"
    git config --global user.email "$EMAIL"
    git config --global user.name "plutov"
    git config --global gpg.format ssh
    git config --global commit.gpgsign true
    git config --global user.signingkey $HOME/.ssh/id_ed25519.pub

    echo "dotfiles installed."
}

function save {
	cp -a $HOME/.zshrc ./
	cp -a $HOME/.env ./
	cp -a $HOME/.yabairc ./
	cp -aR $HOME/.config ./
	echo "dotfiles saved."
}

function show_help {
  echo "Usage: $0 [-i] [-s] [-h]"
  echo "  -i   Install dotfiles"
  echo "  -s   Save dotfiles"
  echo "  -h   Show this help menu"
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

while getopts ":ish" opt; do
  case $opt in
  i) install ;;
  s) save ;;
  h)
    show_help
    exit 0
    ;;
  \?) echo "Invalid option -$OPTARG" ;;
  esac
done
