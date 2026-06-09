# Login-shell setup.
#
# Shared environment is sourced from .zshrc too, so non-login terminals get the
# same PATH, proxy, Node, Flutter, and Podman defaults.
[[ -r "$HOME/.config/zsh/env.zsh" ]] && source "$HOME/.config/zsh/env.zsh"
