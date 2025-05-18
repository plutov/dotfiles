export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
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

PROMPT='%F{227} pluto@earth [%c]%{$reset_color%} '
RPROMPT=''

source "$ZSH"/oh-my-zsh.sh
source "$HOME/.env"

alias vim="nvim"
alias vi="nvim"
alias cat="bat"
