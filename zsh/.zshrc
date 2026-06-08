# 1. P10k 瞬时提示 (必须放在最顶部)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Oh-My-Zsh / 补全系统初始化
export ZSH_COMPDUMP="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
export ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' frequency 7

if [[ -d "$HOME/.oh-my-zsh/custom/completions" ]]; then
  fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)
fi

autoload -Uz compinit
compinit

# 3. 加载发行版/本机可选配置与 P10k 主题
if [[ -r /usr/share/cachyos-zsh-config/cachyos-config.zsh ]]; then
  source /usr/share/cachyos-zsh-config/cachyos-config.zsh
fi

[[ ! -r "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"

# 4. Node & Package Manager
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

if [[ -n "${PNPM_HOME:-}" && -r "$PNPM_HOME/completion.zsh" ]]; then
  source "$PNPM_HOME/completion.zsh"
fi

# 5. 自动建议颜色与交互优化
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan,bold'
unsetopt correct_all

# 6. 编译补全文件以加速加载
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump-${ZSH_VERSION}"
if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
fi

# lsd
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias l='lsd -l'
  alias la='lsd -a'
  alias lla='lsd -la'
  alias lt='lsd --tree'
else
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
fi
# lsd end

# ssh-agent
# Keep Git-over-SSH usable across common Linux distributions.
# This only references the default key path and never reads or prints key content.
_dotfiles_setup_ssh_agent() {
  command -v ssh-agent >/dev/null 2>&1 || return 0
  command -v ssh-add >/dev/null 2>&1 || return 0

  local ssh_env="$HOME/.ssh/agent-env"
  local default_key="$HOME/.ssh/id_ed25519"
  local ssh_add_status=2

  ssh-add -l >/dev/null 2>&1
  ssh_add_status=$?

  if [[ -n "${SSH_AUTH_SOCK:-}" && "$ssh_add_status" -lt 2 ]]; then
    :
  elif [[ -r "$ssh_env" ]]; then
    source "$ssh_env" >/dev/null 2>&1
    if [[ -z "${SSH_AGENT_PID:-}" ]] || ! kill -0 "$SSH_AGENT_PID" >/dev/null 2>&1; then
      ssh-agent -s >| "$ssh_env"
      chmod 600 "$ssh_env"
      source "$ssh_env" >/dev/null 2>&1
    fi
  else
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-agent -s >| "$ssh_env"
    chmod 600 "$ssh_env"
    source "$ssh_env" >/dev/null 2>&1
  fi

  if [[ -f "$default_key" ]]; then
    ssh-add -l 2>/dev/null | grep -F "$default_key" >/dev/null 2>&1 || ssh-add "$default_key" >/dev/null 2>&1
  fi
}

_dotfiles_setup_ssh_agent
unset -f _dotfiles_setup_ssh_agent


# Load dotenv secrets encrypted by sops.
load_sops_env() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  if ! command -v sops >/dev/null 2>&1; then
    echo "sops not found, skip loading secrets: $file" >&2
    return 1
  fi

  set -a
  source <(sops -d "$file")
  set +a
}

# 默认不在 shell 启动时解密 secrets。需要时显式启用：
# export DOTFILES_LOAD_GLOBAL_SOPS_ENV=1
if [[ "${DOTFILES_LOAD_GLOBAL_SOPS_ENV:-0}" == "1" ]]; then
  load_sops_env "$HOME/dotfiles/secrets/global.sops.env"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
