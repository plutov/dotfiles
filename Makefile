.PHONY: all
all: zsh dotfiles brew

.PHONY: brew

BREW_PROGRAMS = zsh jq node yarn
CASC_PROGRAMS = flux
brew: ## Install programs with brew
	if [ ! -f "/usr/local/bin/brew" ]; then \
    	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

	brew update

	$(foreach program,$(BREW_PROGRAMS),brew install $(program) || brew upgrade $(program);)
	$(foreach program,$(CASC_PROGRAMS),brew install $(program) --cask || echo "$(program) already installed";)

	# go
	if [ ! -f "/usr/local/bin/go" ]; then \
		brew install go; \
	fi


.PHONY: dotfiles
dotfiles: ## Copy dotfiles to HOME folder
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".git" -not -name ".DS_Store" -not -name ".swp"); do \
		\cp -r $$file $(HOME)/$$f; \
	done; \
	\cp -r settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json

.PHONY: zsh
zsh: ## Install zsh plugins
	mkdir -p $(HOME)/.oh-my-zsh/custom/plugins/

	if [ ! -d "$(HOME)/gh" ]; then \
		git clone git@github.com:jdxcode/gh.git $(HOME)/gh; \
	fi

	if [ ! -d "$(HOME)/.oh-my-zsh/custom/plugins/gh" ]; then \
		mv -n $(HOME)/gh/zsh/gh $(HOME)/.oh-my-zsh/custom/plugins/; \
	fi

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
