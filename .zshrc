export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Use nvim as editor
export MANPAGER='nvim +Man!'
export EDITOR="$(which nvim)"
export VISUAL="$EDITOR"

# Development settings
#export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
export GOPROXY="https://proxy.golang.org,direct"

# Shell settings
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source <(fzf --zsh)
source "$HOME/.env"
source "$HOME/.cargo/env"
eval "$(starship init zsh)"

# Aliases
alias vim="nvim"
alias vi="nvim"
alias cat="bat"
alias gaa='git add -A'
alias gf='git fetch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git status'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gcsm='git commit -S -m'

# push current branch with an empty commit message
function push() {
  git add -A && git commit --allow-empty-message -m '' && git push
}
