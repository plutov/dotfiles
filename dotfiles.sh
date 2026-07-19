#!/bin/bash

EMAIL="a.pliutau@gmail.com"

DOTFILES=(
  "$HOME/.zshrc:.zshrc"
  "$HOME/.config/ghostty/config:ghostty.config"
  "$HOME/.config/ghostty/themes:ghostty-themes"
  "$HOME/.config/nvim:nvim"
  "$HOME/.config/starship.toml:starship.toml"
  "$HOME/.config/yazi/yazi.toml:yazi.toml"
  "$HOME/.config/btop/btop.conf:btop/btop.conf"
  "$HOME/.config/cmux/cmux.json:cmux/cmux.json"
  "$HOME/.config/zed/settings.json:zed/settings.json"
  "$HOME/.config/zed/keymap.json:zed/keymap.json"
  "$HOME/.config/opencode/AGENTS.md:agentic/AGENTS.md"
  "$HOME/.agents/skills:agentic/skills"
  "$HOME/.pi/agent/AGENTS.md:pi/AGENTS.md"
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

  copy_with_mkdir "pi/settings.json" "$HOME/.pi/agent/settings.json"

  touch ~/.hushlogin
}

save() {
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$destination" "$source"
  done

  copy_with_mkdir "$HOME/.pi/agent/settings.json" "pi/settings.json"

  echo "Dotfiles saved."
}

install() {
  update_brew=false

  if [[ $(command -v brew) == "" ]]; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    PATH="/opt/homebrew/bin:$PATH"
  else
    update_brew=true
  fi

  echo "Trusting the Mole Homebrew formula"
  brew trust --formula tw93/tap/mole

  if $update_brew; then
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
  git config --global core.excludesfile ~/.gitignore
  git config --global user.email "$EMAIL"
  git config --global user.name "plutov"
  git config --global gpg.format ssh
  git config --global commit.gpgsign true
  git config --global user.signingkey "$HOME"/.ssh/id_ed25519.pub
  git config --global pull.rebase true

  echo "Installing pi extensions"
  pi install npm:pi-system-theme

  echo "dotfiles installed and configured."
}

show_help() {
  echo "Usage: $0 [-i|-a|-s] [-h]"
  echo "  -i            Install tools"
  echo "  -a            Apply dotfiles"
  echo "  -s            Save dotfiles"
  echo "  -h            Show this help menu"
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

ACTIONS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
  -i)
    ACTIONS+=("install")
    shift
    ;;
  -a)
    ACTIONS+=("apply")
    shift
    ;;
  -s)
    ACTIONS+=("save")
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    echo "Invalid option $1"
    show_help
    exit 1
    ;;
  esac
done

if [[ ${#ACTIONS[@]} -eq 0 ]]; then
  show_help
  exit 0
fi

for action in "${ACTIONS[@]}"; do
  case "$action" in
  install) install ;;
  apply) apply ;;
  save) save ;;
  esac
done
