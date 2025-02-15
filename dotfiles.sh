#!/bin/bash

EMAIL="a.pliutau@gmail.com"

DOTFILES=(
	"$HOME/.zshrc:.zshrc"
	"$HOME/.p10k.zsh:.p10k.zsh"
	"$HOME/.config/zed/settings.json:zed.json"
	"$HOME/.config/ghostty/config:ghostty.config"
	"$HOME/.colima/default/colima.yaml:colima.yaml"
	"$HOME/.config/nvim/init.lua:nvim/init.lua"
	"$HOME/.config/nvim/lua/config/lazy.lua:nvim/lua/config/lazy.lua"
	"$HOME/.config/nvim/lua/plugins/plugins.lua:nvim/lua/plugins/plugins.lua"
)

copy_with_mkdir() {
	source="$1"
	destination="$2"
	dest_dir=$(dirname "$destination")

	mkdir -p "$dest_dir"
	cp -a "$source" "$destination"
}

apply() {
	for dotfile in "${DOTFILES[@]}"; do
		destination="${dotfile%%:*}"
		source="${dotfile##*:}"
		copy_with_mkdir "$source" "$destination"
	done

	if [[ ! -e /var/run/docker.sock ]]; then
		sudo ln -sf "$HOME"/.colima/default/docker.sock /var/run/docker.sock
	fi

	touch ~/.hushlogin

	if [ ! -f "$HOME/.env" ]; then
		copy_with_mkdir ".env" "$HOME/.env"
	fi
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
	else
		cd "$autosuggestions_dir" && git pull
		cd - || exit
	fi

	if [ ! -d "$powerlevel10k_dir" ]; then
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$powerlevel10k_dir"
	else
		cd "$powerlevel10k_dir" && git pull
		cd - || exit
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

	echo "Installing Homebrew packages"
	PACKAGES=(
		"neovim" "ripgrep" "luarocks" "protobuf" "stylua" "shfmt" "shellcheck" "golang" "golangci-lint" "sqlc" "vegeta" "yaml-language-server" "prettier" "git" "git-lfs" "zig" "fzf"
		"colima" "qemu" "docker" "kubectl" "helm" "kube-linter" "kubescape" "derailed/k9s/k9s" "chart-testing" "postgresql" "jesseduffield/lazydocker/lazydocker"
		"btop" "fastfetch" "bat")

	for package in "${PACKAGES[@]}"; do
		brew install "$package"
	done

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
