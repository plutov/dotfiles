#!/bin/bash

EMAIL="a.pliutau@gmail.com"

DOTFILES=(
  "$HOME/.zshrc:.zshrc"
  "$HOME/.ssh/config:.ssh_config"
  "$HOME/.gitignore:.gitignore"
  "$HOME/.config/ghostty/config:ghostty.config"
  "$HOME/.config/nvim:nvim"
  "$HOME/.config/starship.toml:starship.toml"
  "$HOME/.config/yazi/yazi.toml:yazi.toml"
  "$HOME/Library/Application Support/Code/User/settings.json:vscode.json"
)

copy_with_mkdir() {
  source="$1"
  destination="$2"

  if [[ -d "$source" ]]; then
    mkdir -p "$destination"
    cp -Ra "$source"/* "$destination"
  else
    dest_dir=$(dirname "$destination")
    mkdir -p "$dest_dir"
    cp -a "$source" "$destination"
  fi
}

apply() {
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$source" "$destination"
  done

  touch ~/.hushlogin
}

save() {
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$destination" "$source"
  done
  echo "Dotfiles saved."
}

install() {
  if [[ $(command -v brew) == "" ]]; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    PATH="/opt/homebrew/bin:$PATH"
  else
    echo "Updating Homebrew"
    brew update
  fi

  echo "Installing brew packages"
  brew bundle

  echo "Installing nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash

  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating ssh key"
    ssh-keygen -t ed25519 -N "" -C "$EMAIL" -f "$HOME"/.ssh/id_ed25519
  fi

  echo "Configuring git settings"
  git lfs install
  git config --global user.email "$EMAIL"
  git config --global user.name "plutov"
  git config --global gpg.format ssh
  git config --global commit.gpgsign true
  git config --global user.signingkey "$HOME"/.ssh/id_ed25519.pub
  git config --global pull.rebase true

  echo "dotfiles installed and configured."
}

show_help() {
  echo "Usage: $0 [-i] [-s] [-h]"
  echo "  -i   Install tools"
  echo "  -a   Apply dotfiles"
  echo "  -s   Save dotfiles"
  echo "  -h   Show this help menu"
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

while getopts ":isah" opt; do
  case $opt in
  i) install ;;
  s) save ;;
  a) apply ;;
  h)
    show_help
    exit 0
    ;;
  \?) echo "Invalid option -$OPTARG" ;;
  esac
done
