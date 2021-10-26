.PHONY: all
all: zsh dotfiles brew vim

.PHONY: brew

BREW_PROGRAMS = jq kubectl nodejs bat telnet hugo kubernetes-helm httpie watch gotop lazydocker
CASC_PROGRAMS = flux google-chrome visual-studio-code
brew: ## Install programs with brew
	if [ ! -f "/usr/local/bin/brew" ]; then \
    	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby; \
	fi

	brew update
	brew tap cjbassi/gotop
	brew tap jesseduffield/lazydocker

	$(foreach program,$(BREW_PROGRAMS),brew install $(program) || brew upgrade $(program);)
	$(foreach program,$(CASC_PROGRAMS),brew cask install $(program) || echo "$(program) already installed";)

	# go
	if [ ! -f "/usr/local/bin/go" ]; then \
		brew install go; \
	fi

	# gcloud
	if [ ! -d "$(HOME)/google-cloud-sdk" ]; then \
		mkdir $(HOME)/google-cloud-sdk; \
		curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-229.0.0-darwin-x86_64.tar.gz | tar xvz - -C $(HOME)/; \
		gcloud init; \
	fi

	gcloud components update

	# o
	if [ ! -f "/usr/local/bin/o" ]; then \
		rm -rf ~/o.tmp; \
		git clone git@github.com:plutov/o.git ~/o.tmp; \
		~/o.tmp/install.sh; \
		rm -rf ~/o.tmp; \
	fi

.PHONY: dotfiles
dotfiles: ## Copy dotfiles to HOME folder
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".git" -not -name ".DS_Store" -not -name ".swp"); do \
		\cp $$file $(HOME)/$$f; \
	done; \
	\cp settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json

.PHONY: zsh
zsh: ## Install zsh plugins
	if [ ! -d "$(HOME)/gh" ]; then \
		git clone git@github.com:jdxcode/gh.git $(HOME)/gh; \
	fi

	if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/gh" ]; then \
		mv -n $(HOME)/gh/zsh/gh $(HOME)/.oh-my-zsh/custom/plugins/; \
	fi

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: vim
vim: ## Set up vim
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	\cp -R .vim $(HOME)/; \
	\cp .vimrc $(HOME)/.vimrc; \
