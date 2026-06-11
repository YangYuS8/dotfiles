# Shared zsh environment for login and interactive shells.

export BROWSER="${BROWSER:-firefox}"
export TERMINAL="${TERMINAL:-alacritty}"
export QT_QPA_PLATFORMTHEME="${QT_QPA_PLATFORMTHEME:-qt5ct}"

if [[ -z "${TERM:-}" || "$TERM" == "dumb" ]]; then
  export TERM=alacritty
fi

export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export PUB_HOSTED_URL="${PUB_HOSTED_URL:-https://pub.flutter-io.cn}"
export FLUTTER_STORAGE_BASE_URL="${FLUTTER_STORAGE_BASE_URL:-https://storage.flutter-io.cn}"

export NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24,192.168.0.0/16,10.0.0.0/8,*.local}"
if [[ "${DOTFILES_ENABLE_PROXY:-1}" == "1" ]]; then
  export ALL_PROXY="${ALL_PROXY:-http://127.0.0.1:7890}"
  export HTTP_PROXY="${HTTP_PROXY:-http://127.0.0.1:7890}"
  export HTTPS_PROXY="${HTTPS_PROXY:-http://127.0.0.1:7890}"
fi

if [[ -n "${XDG_RUNTIME_DIR:-}" && -S "$XDG_RUNTIME_DIR/podman/podman.sock" ]]; then
  export DOCKER_HOST="${DOCKER_HOST:-unix://$XDG_RUNTIME_DIR/podman/podman.sock}"
fi

typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/.bun/bin"
  "$PNPM_HOME"
  "$PNPM_HOME/bin"
  "$HOME/go/bin"
  $path
)
export PATH

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
