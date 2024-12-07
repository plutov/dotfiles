#!/bin/bash

EMAIL="a.pliutau@gmail.com"

function install {
	cp -a ./.zshrc $HOME/
    cp -aR ./.config $HOME/

    # install ohmyzsh
    if [ ! -f "$HOME/.env" ]; then
        cp -a ./.env $HOME/
    fi

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
    brew install golang vegeta helm kube-linter protobuf kubectl kubescape neovim postgresql derailed/k9s/k9s chart-testing yamllint golangci-lint sqlc yaml-language-server
    if [[ $(command -v brew) == "" ]]; then
        brew install --cask google-cloud-sdk
        gcloud components install gke-gcloud-auth-plugin
    else
        gcloud components update
    fi

    # installs nvm (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

    # install dev tools
    go install golang.org/x/tools/gopls@latest
    go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
    go install github.com/dadav/helm-schema/cmd/helm-schema@latest

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
