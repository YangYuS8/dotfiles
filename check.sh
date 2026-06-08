#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

status=0

check_absent() {
  local description="$1"
  local pattern="$2"
  shift 2

  if grep -RInE --exclude-dir=.git --exclude='*.sops.env' "$pattern" "$@" >/tmp/dotfiles-check-match.$$ 2>/dev/null; then
    echo "[FAIL] $description" >&2
    cat /tmp/dotfiles-check-match.$$ >&2
    status=1
  else
    echo "[OK] $description"
  fi

  rm -f /tmp/dotfiles-check-match.$$
}

if command -v zsh >/dev/null 2>&1; then
  for file in zsh/.zshenv zsh/.zprofile zsh/.zshrc; do
    zsh -n "$file"
    echo "[OK] zsh syntax: $file"
  done
else
  echo "[WARN] zsh not found; skip zsh syntax checks" >&2
fi

shopt -s globstar nullglob
agents_files=(**/AGENTS.md)
if (( ${#agents_files[@]} )); then
  echo "[FAIL] no AGENTS.md files" >&2
  printf '%s\n' "${agents_files[@]}" >&2
  status=1
else
  echo "[OK] no AGENTS.md files"
fi
shopt -u globstar nullglob

check_absent "no hardcoded /home/yangyus8 outside git/secrets" '/home/yangyus8' README.md README.zh-Hans.md zsh stow.sh
check_absent "README is not limited to CachyOS" 'CachyOS / Arch|CachyOS / Arch-like|主要面向 CachyOS' README.md README.zh-Hans.md
check_absent "helper scripts do not use stow --adopt" 'stow[[:space:]][^\n]*--adopt' stow.sh

exit "$status"
