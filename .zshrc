export ZSH="$HOME/.oh-my-zsh"
export PATH=/usr/local/bin:$HOME/go/bin:/opt/homebrew/bin:$PATH

source ~/.env

plugins=(
	git
	zsh-autosuggestions
)

ZSH_THEME="robbyrussell"

source "$ZSH"/oh-my-zsh.sh

alias vim="nvim"
alias vi="nvim"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
