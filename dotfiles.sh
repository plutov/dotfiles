#!/bin/bash

EMAIL="a.pliutau@gmail.com"

DOTFILES=(
	"$HOME/.zshrc:.zshrc"
	"$HOME/.config/zed/settings.json:zed.json"
	"$HOME/.config/ghostty/config:ghostty.config"
	"$HOME/.config/nvim:nvim"
	"$HOME/.config/zellij:zellij"
)

copy_with_mkdir() {
	source="$1"
	destination="$2"

	if [[ -d "$source" ]]; then
		mkdir -p "$destination"
		cp -Ra "$source"/* "$destination"
	else
		dest_dir=$(dirname "$destination")
		mkdir -p "$dest_dir"
		cp -a "$source" "$destination"
	fi
}

apply() {
	for dotfile in "${DOTFILES[@]}"; do
		destination="${dotfile%%:*}"
		source="${dotfile##*:}"
		copy_with_mkdir "$source" "$destination"
	done

	touch ~/.hushlogin
}

save() {
	for dotfile in "${DOTFILES[@]}"; do
		destination="${dotfile%%:*}"
		source="${dotfile##*:}"
		copy_with_mkdir "$destination" "$source"
	done
	echo "Dotfiles saved."
}

install() {
	if [[ ! -e /var/run/docker.sock ]]; then
		sudo ln -sf "$HOME"/.colima/default/docker.sock /var/run/docker.sock
	fi

	# install ohmyzsh
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		echo "Installing oh-my-zsh"
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	fi

	# install ohmyzsh plugins
	autosuggestions_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	powerlevel10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

	if [ ! -d "$autosuggestions_dir" ]; then
		git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
	fi

	if [ ! -d "$powerlevel10k_dir" ]; then
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$powerlevel10k_dir"
	fi

	# install nerdfont
	curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
	~/.local/bin/getnf -i GeistMono

	# install homebrew
	if [ ! -d "$HOME/brew" ]; then
		echo "Installing Homebrew..."
		mkdir "$HOME/brew"
		curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/brew"
		echo "Homebrew installed successfully in $HOME/brew"
	else
		echo "Homebrew already exists in $HOME/brew"
	fi

	export PATH=/usr/local/bin:$HOME/go/bin:$HOME/brew/bin

	echo "Updating Homebrew"
	brew update

	echo "Installing brew packages"
	brew bundle

	echo "Configuring git and ssh key"
	if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
		echo "Generating ssh key"
		ssh-keygen -t ed25519 -N "" -C "$EMAIL" -f "$HOME"/.ssh/id_ed25519
	fi

	git lfs install
	git config --global user.email "$EMAIL"
	git config --global user.name "plutov"
	git config --global gpg.format ssh
	git config --global commit.gpgsign true
	git config --global user.signingkey "$HOME"/.ssh/id_ed25519.pub

	echo "dotfiles installed."
}

show_help() {
	echo "Usage: $0 [-i] [-s] [-h]"
	echo "  -i   Install tools"
	echo "  -a   Apply dotfiles"
	echo "  -s   Save dotfiles"
	echo "  -h   Show this help menu"
}

if [ $# -eq 0 ]; then
	show_help
	exit 0
fi

while getopts ":isah" opt; do
	case $opt in
	i) install ;;
	s) save ;;
	a) apply ;;
	h)
		show_help
		exit 0
		;;
	\?) echo "Invalid option -$OPTARG" ;;
	esac
done
