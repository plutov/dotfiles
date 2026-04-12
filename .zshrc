export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

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

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if command -v npm >/dev/null 2>&1; then
  npm_global_bin="$(npm config get prefix -g 2>/dev/null)/bin"
  if [ -d "$npm_global_bin" ]; then
    export PATH="$npm_global_bin:$PATH"
  fi
fi

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
alias s='source ~/.zshrc'

# push current branch with an empty commit message
function push() {
  git add -A && git commit --allow-empty-message -m '' && git push
}

# toggle macOS dark/light mode (all apps follow via system appearance)
function toggle-mode() {
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
}

# amp
export PATH="$HOME/.local/bin:$PATH"
