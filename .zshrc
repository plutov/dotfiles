if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
export PATH=/usr/local/bin:$HOME/go/bin:$HOME/brew/bin:$HOME/.asdf/shims:$PATH
export DOCKER_HOST=unix:///var/run/docker.sock
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export GOPROXY="https://proxy.golang.org,direct"

plugins=(
	git
	zsh-autosuggestions
	fzf
)

ZSH_THEME="powerlevel10k/powerlevel10k"

source "$ZSH"/oh-my-zsh.sh

alias vim="nvim"
alias vi="nvim"
alias cat="bat"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
