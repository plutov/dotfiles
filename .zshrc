export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
export PATH=/usr/local/bin:$HOME/go/bin:$HOME/brew/bin:$HOME/brew/opt/libpq/bin:$HOME/brew/opt/openjdk/bin:$PATH
export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export GOPROXY="https://proxy.golang.org,direct"

plugins=(
	git
	zsh-autosuggestions
	fzf
)

ZSH_THEME="wuffers"

source "$ZSH"/oh-my-zsh.sh
source "$HOME/.env"

alias vim="nvim"
alias vi="nvim"
alias cat="bat"
