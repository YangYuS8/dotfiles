#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found. Install GNU Stow first." >&2
  exit 1
fi

packages=(
  alacritty
  btop
  direnv
  git
  micro
  neovide
  npm
  nvim
  zellij
  zsh
)

if [[ "${1:-}" == "--apply" ]]; then
  stow -v -t "$HOME" "${packages[@]}"
else
  echo "Dry run only. Re-run with --apply after checking the output."
  stow -nv -t "$HOME" "${packages[@]}"
fi
