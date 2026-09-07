#!/usr/bin/env bash

set -u

EMAIL="a.pliutau@gmail.com"
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FEDORA_PACKAGE_FILE="$REPO_DIR/Fedorafile"
FLATPAK_PACKAGE_FILE="$REPO_DIR/Flatpakfile"

# The same dotfiles are used on both platforms. Package names are kept in
# Brewfile, Fedorafile, and Flatpakfile because the package managers use
# different names.
DOTFILES=(
  "$HOME/.zshrc:$REPO_DIR/.zshrc"
  "$HOME/.config/ghostty/config:$REPO_DIR/ghostty.config"
  "$HOME/.config/ghostty/themes:$REPO_DIR/ghostty-themes"
  "$HOME/.config/nvim:$REPO_DIR/nvim"
  "$HOME/.config/starship.toml:$REPO_DIR/starship.toml"
  "$HOME/.config/zed/settings.json:$REPO_DIR/zed/settings.json"
  "$HOME/.config/zed/keymap.json:$REPO_DIR/zed/keymap.json"
  "$HOME/.local/bin/toggle-system-theme:$REPO_DIR/bin/toggle-system-theme"
  "$HOME/.config/opencode/AGENTS.md:$REPO_DIR/agentic/AGENTS.md"
  "$HOME/.agents/skills:$REPO_DIR/agentic/skills"
  "$HOME/.pi/agent/AGENTS.md:$REPO_DIR/agentic/AGENTS.md"
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

apply() {
  local dotfile destination source
  for dotfile in "${DOTFILES[@]}"; do
    destination="${dotfile%%:*}"
    source="${dotfile##*:}"
    copy_with_mkdir "$source" "$destination"
  done
  rm -f "$HOME/.config/yazi/yazi.toml" "$HOME/.config/btop/btop.conf"
  copy_with_mkdir "$REPO_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
  configure_theme_hotkey
  touch "$HOME/.hushlogin"
}

configure_theme_hotkey() {
  local os_id=""
  local schema="org.gnome.settings-daemon.plugins.media-keys"
  local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/toggle-system-theme/"
  local keybindings

  [[ -r /etc/os-release ]] && . /etc/os-release && os_id="${ID:-}"
  [[ "$os_id" == fedora ]] || return 0
  command -v gsettings >/dev/null 2>&1 || return 0
  keybindings="$(gsettings get "$schema" custom-keybindings 2>/dev/null)" || return 0
  if [[ "$keybindings" == "@as []" || "$keybindings" == "[]" ]]; then
    keybindings="['$path']"
  elif [[ "$keybindings" != *"$path"* ]]; then
    keybindings="${keybindings%]}, '$path']"
  fi
  gsettings set "$schema" custom-keybindings "$keybindings"
  gsettings set "$schema.custom-keybinding:$path" name 'Toggle system theme'
  gsettings set "$schema.custom-keybinding:$path" command "$HOME/.local/bin/toggle-system-theme"
  gsettings set "$schema.custom-keybinding:$path" binding '<Alt><Shift>l'
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
  install_fedora_flatpak_packages
  install_fedora_extra_tools
  install_nvm
}

install_fedora_flatpak_packages() {
  if ! command -v flatpak >/dev/null 2>&1; then
    echo "flatpak is not available; skipping Flatpak packages." >&2
    return 0
  fi

  echo "Adding the Flathub remote"
  if ! sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
    echo "Warning: could not add the Flathub remote; skipping Flatpak packages." >&2
    return 0
  fi

  local package
  while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    if ! sudo flatpak install -y flathub "$package"; then
      echo "Warning: Flatpak package '$package' could not be installed; skipping." >&2
    fi
  done <"$FLATPAK_PACKAGE_FILE"
}

install_nerd_font() {
  local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  local archive
  if find "$font_dir" -type f -name '*.ttf' -print -quit 2>/dev/null | grep -q .; then
    return 0
  fi
  archive="$(mktemp)"
  echo "Installing JetBrains Mono Nerd Font"
  if curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o "$archive" &&
    mkdir -p "$font_dir" && unzip -oq "$archive" -d "$font_dir"; then
    rm -f "$archive"
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$HOME/.local/share/fonts"
  else
    rm -f "$archive"
    echo "Warning: could not install JetBrains Mono Nerd Font." >&2
  fi
}

install_fedora_extra_tools() {
  mkdir -p "$HOME/.local/bin"
  install_nerd_font

  if ! command -v herdr >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/herdr" ]]; then
    echo "Installing Herdr from its official installer"
    curl -fsSL https://herdr.dev/install.sh | sh ||
      echo "Warning: could not install Herdr." >&2
  fi

  if ! command -v zed >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/zed" ]]; then
    echo "Installing Zed from its official installer"
    curl -fsSL https://zed.dev/install.sh | sh ||
      echo "Warning: could not install Zed." >&2
  fi

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
