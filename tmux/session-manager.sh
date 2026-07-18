#!/usr/bin/env bash
set -euo pipefail

if ! command -v fzf >/dev/null 2>&1; then
  printf 'fzf is required for the tmux session picker.\n' >&2
  exit 1
fi

while true; do
  selected=$(
    tmux list-sessions -F '#S' |
      fzf \
        --prompt='tmux session> ' \
        --border \
        --reverse \
        --expect=enter,r,x,n \
        --header='enter: open | r: rename | x: kill | n: new | esc: quit'
  ) || exit 0

  key=$(printf '%s\n' "$selected" | sed -n '1p')
  session=$(printf '%s\n' "$selected" | sed -n '2p')

  case "$key" in
    enter | '')
      [[ -n "$session" ]] && tmux switch-client -t "$session"
      exit 0
      ;;
    r)
      [[ -n "$session" ]] || continue
      printf 'Rename %s to: ' "$session"
      read -r new_name
      [[ -n "$new_name" ]] && tmux rename-session -t "$session" "$new_name"
      ;;
    x)
      [[ -n "$session" ]] || continue
      printf 'Kill %s? [y/N] ' "$session"
      read -r confirm
      [[ "$confirm" =~ ^[Yy]$ ]] && tmux kill-session -t "$session"
      ;;
    n)
      printf 'New session name: '
      read -r new_name
      if [[ -n "$new_name" ]]; then
        tmux new-session -ds "$new_name"
        tmux switch-client -t "$new_name"
        exit 0
      fi
      ;;
  esac
done
