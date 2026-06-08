# ==================== 基础环境与 UI 变量 ====================
export BROWSER=firefox
export TERM=alacritty
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK_THEME=adw-gtk3-dark

# ==================== 网络代理配置 ====================
export NO_PROXY='localhost,127.0.0.1,10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24,192.168.0.0/16,10.0.0.0/8,*.local'
export ALL_PROXY=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890

# ==================== 开发环境与路径 ====================
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$HOME/.bun/bin:$PATH"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

if [[ -n "${XDG_RUNTIME_DIR:-}" && -S "$XDG_RUNTIME_DIR/podman/podman.sock" ]]; then
    export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
fi

# 路径去重与合并
typeset -U path
path=(
    "$PNPM_HOME"
    "$HOME/.local/bin"
    "$HOME/go/bin"
    $path
)
export PATH

# 加载外部环境脚本
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
