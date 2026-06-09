# CachyOS loads its own instant prompt block. On other systems, keep p10k close
# to the top of .zshrc.
if [[ ! -r /usr/share/cachyos-zsh-config/cachyos-config.zsh && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ $- != *i* ]] && return

[[ -r "$HOME/.config/zsh/env.zsh" ]] && source "$HOME/.config/zsh/env.zsh"

# Completion and shell framework setup.
export ZSH_COMPDUMP="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump-${ZSH_VERSION}}"
export ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' frequency 7

if [[ -d "$HOME/.oh-my-zsh/custom/completions" ]]; then
  fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)
fi

if [[ -r /usr/share/cachyos-zsh-config/cachyos-config.zsh ]]; then
  source /usr/share/cachyos-zsh-config/cachyos-config.zsh
else
  autoload -Uz compinit
  compinit -d "$ZSH_COMPDUMP"

  [[ -r /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]] && source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

if [[ -n "${PNPM_HOME:-}" && -r "$PNPM_HOME/completion.zsh" ]]; then
  source "$PNPM_HOME/completion.zsh"
fi

# Interactive behavior.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan,bold'
unsetopt correct_all

if [[ -s "$ZSH_COMPDUMP" && (! -s "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc") ]]; then
  zcompile "$ZSH_COMPDUMP"
fi

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
  source <(sops -d --input-type dotenv --output-type dotenv "$file")
  set +a
}

# Secrets are not decrypted on shell startup. Enable this explicitly if needed:
# export DOTFILES_LOAD_GLOBAL_SOPS_ENV=1
if [[ "${DOTFILES_LOAD_GLOBAL_SOPS_ENV:-0}" == "1" ]]; then
  load_sops_env "$HOME/dotfiles/secrets/global.sops.env"
fi

_dotfiles_npm_userconfig() {
  local token="${NPM_TOKEN:-${NODE_AUTH_TOKEN:-}}"
  local secrets_file="${DOTFILES_NPM_SOPS_ENV:-$HOME/dotfiles/secrets/npm.sops.env}"

  if [[ -z "$token" && -f "$secrets_file" ]]; then
    load_sops_env "$secrets_file" || return 1
    token="${NPM_TOKEN:-${NODE_AUTH_TOKEN:-}}"
  fi

  if [[ -z "$token" ]]; then
    echo "NPM_TOKEN is not set, and no token was loaded from $secrets_file" >&2
    return 1
  fi

  local dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/dotfiles-npm"
  mkdir -p "$dir"
  chmod 700 "$dir" 2>/dev/null || true

  local config="$dir/npmrc"
  (
    umask 077
    {
      print -r -- "registry=https://registry.npmjs.org/"
      print -r -- "//registry.npmjs.org/:_authToken=$token"
    } >| "$config"
  )

  print -r -- "$config"
}

npm-auth() {
  local config
  config="$(_dotfiles_npm_userconfig)" || return $?
  NPM_CONFIG_USERCONFIG="$config" npm "$@"
}

pnpm-auth() {
  local config
  config="$(_dotfiles_npm_userconfig)" || return $?
  NPM_CONFIG_USERCONFIG="$config" pnpm "$@"
}

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
