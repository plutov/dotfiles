export ZSH="$HOME/.oh-my-zsh"
export GOPATH="$HOME/go"
export PATH=/usr/local/lib/ruby/gems/2.7.0/bin:/usr/local/bin/:$HOME/go/bin:/usr/local/go/bin:$PATH
export GH_BASE_DIR="$HOME/go/src"
export LANG=C
export ANDROID_SDK_ROOT="/Users/alex/Library/Android/sdk"
export GOSUMDB=off

ZSH_THEME="af-magic"

plugins=(
  git gh
)

source $ZSH/oh-my-zsh.sh
source ~/.functions
source ~/.env

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
