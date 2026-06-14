#!/bin/bash

EMAIL="a.pliutau@gmail.com"
TARGET="personal"

DOTFILES=(
  "$HOME/.zshrc:.zshrc"
  "$HOME/.config/ghostty/config:ghostty.config"
  "$HOME/.config/ghostty/themes:ghostty-themes"
  "$HOME/.config/nvim:nvim"
  "$HOME/.config/starship.toml:starship.toml"
  "$HOME/.config/yazi/yazi.toml:yazi.toml"
  "$HOME/.config/zed/settings.json:zed/settings.json"
  "$HOME/.config/zed/keymap.json:zed/keymap.json"
  "$HOME/.config/opencode/AGENTS.md:agentic/AGENTS.md"
  "$HOME/.agents/skills:agentic/skills"
  "$HOME/.pi/agent/AGENTS.md:pi/AGENTS.md"
  "$HOME/.pi/agent/system-theme.json:pi/system-theme.json"
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

pi_settings_source() {
  case "$TARGET" in
  personal) echo "pi/settings.personal.json" ;;
  work) echo "pi/settings.work.json" ;;
  *)
    echo "Invalid --target: $TARGET (expected: work|personal)"
    exit 1
    ;;
  esac
}

apply() {
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$source" "$destination"
  done

  copy_with_mkdir "$(pi_settings_source)" "$HOME/.pi/agent/settings.json"

  touch ~/.hushlogin
}

save() {
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$destination" "$source"
  done

  copy_with_mkdir "$HOME/.pi/agent/settings.json" "$(pi_settings_source)"

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
  echo "Usage: $0 [-i|-a|-s] [--target work|personal] [-h]"
  echo "  -i            Install tools"
  echo "  -a            Apply dotfiles"
  echo "  -s            Save dotfiles"
  echo "  --target      Select pi settings target (default: personal)"
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
  --target)
    TARGET="$2"
    if [[ -z "$TARGET" ]]; then
      echo "Missing value for --target"
      exit 1
    fi
    shift 2
    ;;
  --target=*)
    TARGET="${1#*=}"
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
