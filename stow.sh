#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found. Install GNU Stow first." >&2
  exit 1
fi

default_packages=(
  alacritty
  btop
  desktop
  direnv
  fcitx5
  git
  micro
  neovide
  npm
  nvim
  pnpm
  zellij
  zsh
)

usage() {
  cat <<'EOF'
Usage: ./stow.sh [--apply|--adopt] [package ...]

Without a mode this runs a dry run. Pass package names to limit the operation.
Use --adopt once for files that already exist in $HOME and should become
managed by this repository.
EOF
}

mode=dry-run
case "${1:-}" in
  --apply)
    mode=apply
    shift
    ;;
  --adopt)
    mode=adopt
    shift
    ;;
  -h|--help)
    usage
    exit 0
    ;;
esac

packages=("$@")
if [[ "${#packages[@]}" -eq 0 ]]; then
  packages=("${default_packages[@]}")
fi

case "$mode" in
  apply)
    stow -v -t "$HOME" "${packages[@]}"
    ;;
  adopt)
    stow -v --adopt -t "$HOME" "${packages[@]}"
    ;;
  dry-run)
    echo "Dry run only. Re-run with --apply after checking the output."
    echo "For existing unmanaged files, use --adopt after confirming the diff."
    stow -nv -t "$HOME" "${packages[@]}"
    ;;
esac
