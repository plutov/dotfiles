#!/bin/bash

EMAIL="a.pliutau@gmail.com"

declare -A DOTFILES=(
	.zshrc="$HOME/.zshrc"
	.p10k.zsh="$HOME/.p10k.zsh"
	nvim="$HOME/.config/nvim"
	zed.json="$HOME/.config/zed/settings.json"
	ghostty.config="$HOME/.config/ghostty/config"
	colima.yaml="$HOME/.colima/default/colima.yaml"
)

copy_with_mkdir() {
	local source="$1"
	local destination="$2"
	local dest_dir=$(dirname "$destination")

	mkdir -p "$dest_dir"
	cp -a "$source" "$destination"
}

apply() {
	for source in "${!DOTFILES[@]}"; do
		destination="${DOTFILES[$source]}"
		copy_with_mkdir "$source" "$destination"
	done

	# Colima docker socket symlink
	if [[ ! -e /var/run/docker.sock ]]; then
		sudo ln -sf "$HOME"/.colima/default/docker.sock /var/run/docker.sock
	fi

	touch ~/.hushlogin

	if [ ! -f "$HOME/.env" ]; then
		copy_with_mkdir ".env" "$HOME/.env"
	fi
}

save() {
	for source in "${!DOTFILES[@]}"; do
		destination="${DOTFILES[$source]}"
		copy_with_mkdir "$destination" "$source" # Save back to current dir
	done
	echo "Dotfiles saved."
}

function install {
	# install ohmyzsh
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		echo "Installing oh-my-zsh"
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	fi

	# install ohmyzsh plugins
	git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

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
	# coding, lsp
	brew install neovim ripgrep luarocks \
		protobuf stylua shfmt shellcheck \
		golang golangci-lint sqlc vegeta \
		yaml-language-server prettier git git-lfs \
		zig fzf

	# containers
	brew install colima qemu docker kubectl helm kube-linter kubescape derailed/k9s/k9s chart-testing postgresql jesseduffield/lazydocker/lazydocker

	# workspace
	brew install btop fastfetch bat

	# gcloud
	if [[ $(command -v gcloud) == "" ]]; then
		brew install --cask google-cloud-sdk
		gcloud components install gke-gcloud-auth-plugin
	else
		gcloud components update
	fi

	# installs nvm (Node Version Manager)
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

	export PATH=/usr/local/bin:$HOME/go/bin:/opt/homebrew/bin:$PATH

	# install dev tools
	go install golang.org/x/tools/gopls@latest
	go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
	go install github.com/dadav/helm-schema/cmd/helm-schema@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install mvdan.cc/gofumpt@latest
	go install github.com/google/yamlfmt/cmd/yamlfmt@latest
	npm install -g sql-formatter

	if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
		echo "Generating ssh key"
		ssh-keygen -t ed25519 -N "" -C "$EMAIL" -f "$HOME"/.ssh/id_ed25519
	fi

	echo "Configuring git"
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
