#!/bin/bash

function install {
	rm -rf $HOME/.zshrc
	rm -rf $HOME/.env
	rm -rf $HOME/.config
	rm -rf $HOME/.yabairc
	cp -a ./.zshrc $HOME/
  	cp -a ./.env $HOME/
    cp -a ./.yabairc $HOME/
    cp -aR ./.config $HOME/

    # install ohmyzsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # install nerdfont
    curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
    ~/.local/bin/getnf

    # install homebrew packages
    brew install golang neovim koekeishiya/formulae/yabai

    # start yabai
    yabai --start-service

    # install simple-bar, install Übersicht first - https://tracesof.net/uebersicht/
    mkdir -p ~/code/widgets
    if [ -d "~/code/widgets/simple-bar" ]
    then
    	git clone https://github.com/Jean-Tinland/simple-bar ~/code/widgets/simple-bar
    else
    	cd ~/code/widgets/simple-bar
     	git fetch
      	git pull
    fi

    # Set git config author details
    git config --global user.email "a.pliutau@gmail.com"
    git config --global user.name "plutov"

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
