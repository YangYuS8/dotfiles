# 1. P10k 瞬时提示 (必须放在最顶部)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. 补全系统初始化
fpath=("/home/yangyus8/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit

# 3. Oh-My-Zsh 性能优化
export ZSH_COMPDUMP="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
export ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' frequency 7

# 4. 加载 CachyOS 默认配置与 P10k 主题
source /usr/share/cachyos-zsh-config/cachyos-config.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 5. Node & Package Manager (fnm 替代 nvm)
if (( $+commands[fnm] )); then
  # 极速初始化，不再需要延迟加载脚本
  eval "$(fnm env --use-on-cd)"
fi

# pnpm 补全 (如果该文件存在则加载)
[[ -f "$PNPM_HOME/completion.zsh" ]] && source "$PNPM_HOME/completion.zsh"

# 6. SSH Agent 单例管理与自动添加密钥
SSH_ENV="$HOME/.ssh/agent-env"
_start_agent() {
    ssh-agent -s > "${SSH_ENV}" 2>/dev/null
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    for key in ~/.ssh/id_ed25519_{github,aur}_YangYuS8; do
        [ -f "$key" ] && ssh-add "$key" 2>/dev/null
    done
}

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -p ${SSH_AGENT_PID} > /dev/null 2>&1 || _start_agent
else
    _start_agent
fi
unset _start_agent

# 7. 自动建议颜色与交互优化
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan,bold'
unsetopt correct_all

# 8. 编译补全文件以加速加载
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump-${ZSH_VERSION}"
if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
fi

# lsd
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
# lsd end

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

load_sops_env "$HOME/dotfiles/secrets/global.sops.env"

# direnv
eval "$(direnv hook zsh)"

# pnpm
export PNPM_HOME="/home/yangyus8/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
