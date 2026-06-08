# AGENTS.md

This repository contains my personal dotfiles for CachyOS / Arch-like Linux systems.

The repository should be treated as public. Maintain only non-private, reproducible configuration. Do not collect, inspect, print, move, or commit secrets, private keys, browser profiles, shell history, login sessions, or whole application state directories.

## Purpose

Help maintain the public-safe part of my dotfiles.

Good work includes:

- organizing GNU Stow packages
- improving shell configuration
- improving README documentation
- adding safe config packages
- adding validation scripts
- checking for obvious secret leaks
- making configs more portable
- keeping commits small and focused

Bad work includes:

- backing up the whole home directory
- adding caches
- adding application databases
- adding login state
- adding real tokens
- adding private keys
- dumping environment variables
- decrypting secrets without explicit instruction
- changing secret architecture without approval

## Core tools

This repository uses:

- GNU Stow for symlink management
- Git for version control
- sops + age for encrypted secret files
- direnv for per-project environment loading

Each top-level directory is usually a Stow package. The package layout mirrors paths under `$HOME`.

Example layout:

```text
zsh/.zshrc          -> ~/.zshrc
git/.gitconfig      -> ~/.gitconfig
micro/.config/micro -> ~/.config/micro
npm/.npmrc          -> ~/.npmrc
direnv/.config/direnv/direnvrc -> ~/.config/direnv/direnvrc
```

## Allowed areas

You may modify or maintain these repository files and packages:

```text
README.md
README.zh-Hans.md
AGENTS.md
.gitignore
.sops.yaml
stow.sh
check.sh
zsh/
git/
micro/
npm/
direnv/
alacritty/
btop/
nvim/
neovide/
zellij/
niri/
waybar/
wofi/
wlogout/
swaylock/
mako/
fontconfig/
gtk/
qt/
systemd/
environment/
```

You may add new Stow packages only when the source is clearly non-private configuration.

Good future candidates:

```text
~/.config/alacritty
~/.config/btop
~/.config/nvim
~/.config/neovide
~/.config/zellij
~/.config/niri
~/.config/waybar
~/.config/wofi
~/.config/wlogout
~/.config/swaylock
~/.config/mako
~/.config/fontconfig
~/.config/gtk-3.0
~/.config/gtk-4.0
~/.config/qt5ct
~/.config/qt6ct
~/.config/Kvantum
~/.config/systemd
~/.config/environment.d
```

## Forbidden files and directories

Never add, inspect, copy, move, print, or commit private material.

Forbidden paths include:

```text
~/.ssh/
~/.gnupg/
~/.pki/
~/.docker/
~/.kube/
~/.minikube/
~/.config/sops/age/keys.txt
~/.npmrc if it contains a real token
plaintext .env files
private keys
API tokens
passwords
browser profiles
chat logs
shell history
login/session state
```

Never add these whole directories:

```text
~/.cache
~/.local
~/.var
~/.npm
~/.bun
~/.rustup
~/.pub-cache
~/.gradle
~/.android
~/.java
~/.steam
~/.mozilla
~/.thunderbird
~/.vscode
~/.cursor
~/.oh-my-zsh
```

Some directories may contain individual safe subfiles, but do not add them unless the user explicitly asks and the file has been checked.

## Secret policy

Plaintext secrets must never appear in this repository.

Do not write real values for variables such as:

```text
NPM_TOKEN
GITHUB_TOKEN
GH_TOKEN
OPENAI_API_KEY
ANTHROPIC_API_KEY
GEMINI_API_KEY
API_KEY
PASSWORD
SECRET
TOKEN
```

Allowed pattern:

```ini
//registry.npmjs.org/:_authToken=${NPM_TOKEN}
```

Forbidden pattern:

```ini
//registry.npmjs.org/:_authToken=npm_xxxxxxxxxxxxxxxxx
```

Encrypted files matching this pattern are allowed:

```text
secrets/*.sops.env
```

However, do not decrypt, print, or expose their contents unless the user explicitly requests it and understands the risk.

Never read, print, move, or commit:

```text
~/.config/sops/age/keys.txt
```

This file is the age private key.

## sops + age + direnv rules

The preferred secret architecture is:

```text
dotfiles/secrets/*.sops.env    # encrypted, safe to commit
~/.config/sops/age/keys.txt    # private key, never commit
project/.envrc                 # uses direnv to load selected encrypted env files
```

Safe `.npmrc` example:

```ini
//registry.npmjs.org/:_authToken=${NPM_TOKEN}
```

Safe project `.envrc` example:

```bash
use_sops_env ~/dotfiles/secrets/npm.sops.env
```

Do not put project-specific real tokens in `.zshrc`.

Do not globally load every secret in `.zshrc`. Prefer direnv for project-specific secrets.

## Stow rules

Always preview before applying:

```bash
stow -nv -t ~ package
```

Then apply:

```bash
stow -v -t ~ package
```

Use explicit package names only.

Good:

```bash
stow -v -t ~ zsh git micro npm direnv
```

Bad:

```bash
stow -v -t ~ *
```

Avoid `stow --adopt` unless the user explicitly asks for it and the target files have been inspected.

## Shell config rules

For zsh:

- Keep `.zshenv` minimal.
- Do not put secrets in `.zshrc`, `.zprofile`, or `.zshenv`.
- Prefer `$HOME` over hardcoded `/home/yangyus8`.
- Guard optional commands with `command -v`.
- Guard optional files with `[[ -f ... ]]`.

Good:

```zsh
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
```

Good:

```zsh
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
```

Bad:

```zsh
source "$HOME/.cargo/env"
```

Bad:

```zsh
export NPM_TOKEN="real-token"
```

## Git config rules

A GPG key ID in `.gitconfig` is acceptable:

```ini
[user]
    signingkey = 5766204AC9DBFCBC
```

An SSH public key path is acceptable:

```ini
[user]
    signingkey = ~/.ssh/id_ed25519.pub
```

An SSH private key path is not acceptable:

```ini
[user]
    signingkey = ~/.ssh/id_ed25519
```

Never add SSH private keys.

## Validation before committing

Before committing, run:

```bash
git status
git diff
```

Run the repository check script when available:

```bash
./check.sh
```

Scan for obvious plaintext secrets:

```bash
grep -RniE 'npm[_-]?token|_authToken|token|secret|password|passwd|api[_-]?key|apikey|bearer|ghp_|sk-' . \
  --exclude-dir=.git \
  --exclude='*.md' || true
```

Encrypted `ENC[...]` values inside `*.sops.env` are okay.

Real tokens are not okay.

## Editing workflow

When asked to maintain this repository:

1. Inspect the existing structure.
2. Identify whether the requested file is safe to manage.
3. Refuse or warn before touching private files.
4. Prefer small, focused changes.
5. Update README or README.zh-Hans.md when behavior changes.
6. Run validation checks.
7. Summarize what changed and what was not touched.

## Commit style

Use small commits.

Good commit messages:

```text
Add alacritty stow package
Polish zsh startup guards
Add dotfiles validation script
Document sops and direnv workflow
```

Bad commit messages:

```text
update
fix
sync home
backup all configs
```

## Do not do these things

Do not:

- add the entire home directory
- add caches
- add browser profiles
- add login sessions
- add private keys
- add plaintext secrets
- decrypt and print sops files
- inspect `~/.ssh`, `~/.gnupg`, or age private keys
- run broad commands that dump environment variables, such as `env`, `printenv`, or `set`, unless explicitly asked
- rewrite unrelated configs
- use `stow --adopt` without explicit permission
- change secret architecture without user approval

## When unsure

Stop and ask before touching anything that may contain:

```text
credentials
tokens
private keys
personal data
browser data
chat history
cloud credentials
Kubernetes credentials
Docker credentials
SSH/GPG material
```

The safest default is:

```text
Do not add it.
Do not print it.
Do not commit it.
```
