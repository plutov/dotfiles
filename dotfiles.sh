#!/usr/bin/env bash

set -u

EMAIL="a.pliutau@gmail.com"
TMUX_REPO="https://github.com/gpakosz/.tmux.git"
TMUX_DIR="$HOME/.tmux"
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FEDORA_PACKAGE_FILE="$REPO_DIR/Fedorafile"

# The same dotfiles are used on both platforms. Package names are kept in
# Brewfile and Fedorafile because the package managers use different names.
DOTFILES=(
  "$HOME/.zshrc:$REPO_DIR/.zshrc"
  "$HOME/.tmux.conf.local:$REPO_DIR/.tmux.conf.local"
  "$HOME/.config/ghostty/config:$REPO_DIR/ghostty.config"
  "$HOME/.config/ghostty/themes:$REPO_DIR/ghostty-themes"
  "$HOME/.config/nvim:$REPO_DIR/nvim"
  "$HOME/.config/starship.toml:$REPO_DIR/starship.toml"
  "$HOME/.config/yazi/yazi.toml:$REPO_DIR/yazi.toml"
  "$HOME/.config/btop/btop.conf:$REPO_DIR/btop/btop.conf"
  "$HOME/.config/zed/settings.json:$REPO_DIR/zed/settings.json"
  "$HOME/.config/zed/keymap.json:$REPO_DIR/zed/keymap.json"
  "$HOME/.config/opencode/AGENTS.md:$REPO_DIR/agentic/AGENTS.md"
  "$HOME/.agents/skills:$REPO_DIR/agentic/skills"
  "$HOME/.pi/agent/AGENTS.md:$REPO_DIR/pi/AGENTS.md"
  "$HOME/.pi/agent/extensions/diff.ts:$REPO_DIR/pi/extensions/diff.ts"
  "$HOME/.pi/agent/extensions/subagent/config.json:$REPO_DIR/pi/extensions/subagent/config.json"
)

copy_with_mkdir() {
  local source="$1" destination="$2"
  if [[ ! -e "$source" ]]; then
    echo "Skipping missing source: $source"
    return 0
  fi
  if [[ -d "$source" ]]; then
    mkdir -p "$destination"
    cp -Ra "$source"/. "$destination"/
  else
    mkdir -p "$(dirname "$destination")"
    cp -a "$source" "$destination"
  fi
}

ensure_tmux_config() {
  if [[ -d "$TMUX_DIR/.git" ]]; then
    git -C "$TMUX_DIR" pull --ff-only
  else
    rm -rf "$TMUX_DIR"
    git clone --depth 1 "$TMUX_REPO" "$TMUX_DIR"
  fi
  ln -sfn "$TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
}

apply() {
  local dotfile destination source
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$source" "$destination"
  done
  ensure_tmux_config
  copy_with_mkdir "$REPO_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
  touch "$HOME/.hushlogin"
}

save() {
  local dotfile destination source
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$destination" "$source"
  done
  copy_with_mkdir "$HOME/.pi/agent/settings.json" "$REPO_DIR/pi/settings.json"
  echo "Dotfiles saved."
}

install_macos() {
  local update_brew=false
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH="/opt/homebrew/bin:$PATH"
  else
    update_brew=true
  fi
  echo "Trusting the Mole Homebrew formula"
  brew trust --formula tw93/tap/mole
  $update_brew && brew update
  brew bundle --file="$REPO_DIR/Brewfile"
  install_nvm
}

install_fedora() {
  echo "Installing Fedora packages"
  local package
  if [[ ! -r "$FEDORA_PACKAGE_FILE" ]]; then
    echo "Missing Fedora package list: $FEDORA_PACKAGE_FILE" >&2
    return 1
  fi
  while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    if ! sudo dnf -y install "$package"; then
      echo "Warning: Fedora package '$package' is unavailable; skipping." >&2
    fi
  done <"$FEDORA_PACKAGE_FILE"
  install_fedora_extra_tools
  install_nvm
}

install_fedora_extra_tools() {
  mkdir -p "$HOME/.local/bin"

  if ! command -v starship >/dev/null 2>&1; then
    echo "Installing starship from its prebuilt installer"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" ||
      echo "Warning: could not install starship." >&2
  fi

  if ! command -v lazygit >/dev/null 2>&1; then
    echo "Installing lazygit with go"
    if command -v go >/dev/null 2>&1; then
      GOBIN="$HOME/.local/bin" go install github.com/jesseduffield/lazygit@latest || echo "Warning: could not install lazygit." >&2
    else
      echo "Warning: go is unavailable; skipping lazygit." >&2
    fi
  fi
}

install_nvm() {
  if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
    echo "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
  fi
}

install_common() {
  if command -v zsh >/dev/null 2>&1; then
    local zsh_path current_shell
    zsh_path="$(command -v zsh)"
    current_shell="${SHELL:-}"
    if [[ "$current_shell" != "$zsh_path" ]]; then
      echo "Setting zsh as the default shell"
      chsh -s "$zsh_path" || echo "Warning: could not change the default shell." >&2
    fi
  fi

  echo "Installing tmux configuration"
  ensure_tmux_config
  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    echo "Generating ssh key"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -N "" -C "$EMAIL" -f "$HOME/.ssh/id_ed25519"
  fi
  echo "Configuring git settings"
  git lfs install
  git config --global core.excludesfile ~/.gitignore
  git config --global user.email "$EMAIL"
  git config --global user.name "plutov"
  git config --global gpg.format ssh
  git config --global commit.gpgsign true
  git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub"
  git config --global pull.rebase true

  if command -v pi >/dev/null 2>&1; then
    echo "Installing pi extensions"
    pi install npm:pi-system-theme
    pi install npm:pi-subagents
    pi install npm:pi-zentui
  else
    echo "pi is not installed; skipping pi extensions."
  fi
  echo "dotfiles installed and configured."
}

install() {
  local os_id=""
  [[ -r /etc/os-release ]] && . /etc/os-release && os_id="${ID:-}"
  if [[ "$OSTYPE" == darwin* ]]; then
    install_macos
  elif [[ "$os_id" == fedora ]]; then
    install_fedora
  else
    echo "Unsupported OS. This script supports macOS and Fedora." >&2
    return 1
  fi
  install_common
}

show_help() {
  echo "Usage: $0 [-i|-a|-s] [-h]"
  echo "  -i            Install tools (Homebrew on macOS, dnf on Fedora)"
  echo "  -a            Apply dotfiles"
  echo "  -s            Save dotfiles"
  echo "  -h            Show this help menu"
}

if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi
ACTIONS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
  -i)
    ACTIONS+=(install)
    shift
    ;;
  -a)
    ACTIONS+=(apply)
    shift
    ;;
  -s)
    ACTIONS+=(save)
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
for action in "${ACTIONS[@]}"; do "$action" || exit $?; done
