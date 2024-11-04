export ZSH="$HOME/.oh-my-zsh"
export PATH=/opt/homebrew/lib/ruby/gems/3.2.0/bin:/usr/local/bin:$HOME/go/bin:/opt/homebrew/bin:$HOME/.cargo/bin:$PATH

source ~/.env

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias vim="nvim"
alias vi="nvim"
