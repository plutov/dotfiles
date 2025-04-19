export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

export PATH="$HOME/brew/opt/openjdk/bin:$PATH"
export PATH="$HOME/brew/opt/libpq/bin:$PATH"
export PATH="$HOME/brew/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

export MANPAGER='nvim +Man!'
export EDITOR="$(which nvim)"
export VISUAL="$EDITOR"

export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export GOPROXY="https://proxy.golang.org,direct"

plugins=(
	git
	zsh-autosuggestions
	fzf
)

ZSH_THEME="theunraveler"

source "$ZSH"/oh-my-zsh.sh
source "$HOME/.env"

alias vim="nvim"
alias vi="nvim"
alias cat="bat"
