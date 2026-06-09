# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

Chinese guide: [README.zh-Hans.md](./README.zh-Hans.md)

This repository is meant to restore my core development and desktop configuration on common Linux distributions, including Arch Linux, Debian/Ubuntu, and Fedora. It should contain reproducible configuration, not caches, login sessions, or plaintext secrets.

## Core idea

Each top-level directory is a Stow package. The package mirrors the target path under `$HOME`.

Example:

```text
dotfiles/
├── zsh/
│   ├── .zshrc
│   ├── .zprofile
│   ├── .zshenv
│   └── .p10k.zsh
├── git/
│   └── .gitconfig
└── micro/
    └── .config/micro/
```

After running Stow:

```text
~/.zshrc         -> ~/dotfiles/zsh/.zshrc
~/.gitconfig     -> ~/dotfiles/git/.gitconfig
~/.config/micro  -> ~/dotfiles/micro/.config/micro
```

## Install required tools

Arch Linux:

```bash
sudo pacman -S stow git
```

Debian / Ubuntu:

```bash
sudo apt update
sudo apt install stow git
```

Fedora:

```bash
sudo dnf install stow git
```

Optional tools for encrypted secrets and per-project environment variables:

Arch Linux:

```bash
sudo pacman -S sops age direnv
```

Debian / Ubuntu:

```bash
sudo apt install sops age direnv
```

Fedora:

```bash
sudo dnf install sops age direnv
```

## Apply packages

Always preview first:

```bash
cd ~/dotfiles
./stow.sh zsh
./stow.sh --apply zsh
```

Apply multiple packages explicitly:

```bash
cd ~/dotfiles
./stow.sh --apply zsh git micro
```

Do not blindly run `stow -t ~ *`, because directories such as `secrets/` are not meant to be Stow packages.

## Remove or refresh links

Unstow one package:

```bash
cd ~/dotfiles
stow -D -t ~ zsh
```

Restow one package:

```bash
cd ~/dotfiles
stow -R -t ~ zsh
```

## GitHub to CNB sync

`.github/workflows/sync-to-cnb.yml` mirrors GitHub pushes to CNB:

```text
https://cnb.cool/Nesoriel/YangYuS8/dotfiles
```

Configure this GitHub Actions repository secret:

```text
CNB_TOKEN
```

CNB Git HTTPS authentication uses the fixed username `cnb` and an access token as the password. The token needs write access to the target CNB repository.

## Add an existing config file

Example: add `~/.gitconfig`:

```bash
cd ~/dotfiles
mkdir -p git
mv ~/.gitconfig git/
stow -nv -t ~ git
stow -v -t ~ git
```

Example: add `~/.config/alacritty`:

```bash
cd ~/dotfiles
mkdir -p alacritty/.config
mv ~/.config/alacritty alacritty/.config/
stow -nv -t ~ alacritty
stow -v -t ~ alacritty
```

## Modify a managed config

After Stow creates the symlink, editing either path modifies the same file:

```bash
nvim ~/.zshrc
# same as:
nvim ~/dotfiles/zsh/.zshrc
```

Then commit the change:

```bash
cd ~/dotfiles
git status
git add zsh/.zshrc
git commit -m "Update zsh config"
git push
```

## Handle Stow conflicts

If Stow reports a conflict like this:

```text
cannot stow package over existing target since neither a link nor a directory
```

It means the target already exists and is not managed by Stow.

Preferred fix:

```bash
mv ~/.example ~/.example.bak
stow -nv -t ~ package
stow -v -t ~ package
```

If the old file should be kept, move it into the correct package before running Stow:

```bash
mkdir -p package
mv ~/.example package/
stow -nv -t ~ package
stow -v -t ~ package
```

The helper script also supports adoption for selected packages:

```bash
./stow.sh --adopt package
```

Avoid adoption unless I fully understand what it will move into this repository. Preview the package first with `./stow.sh package`.

## Secrets policy

Never commit plaintext secrets.

Do not put these into this public dotfiles repository:

```text
API tokens
passwords
private keys
~/.ssh/id_*
~/.gnupg/
~/.config/sops/age/keys.txt
plaintext .env files
npm auth tokens
Kubernetes credentials
Docker auth files
```

Allowed:

```text
secrets/*.sops.env    # encrypted by sops
.npmrc                # registry and other public config only, no auth token
.gitconfig signingkey # okay if it is a GPG key ID or public SSH key path
```

Before pushing, scan for obvious leaks:

```bash
cd ~/dotfiles
grep -RniE 'npm[_-]?token|_authToken|token|secret|password|passwd|api[_-]?key|apikey|bearer|ghp_|sk-' .
```

Seeing `ENC[...]` inside `*.sops.env` is fine. Seeing a real token is not fine.

## Recommended secret management

Use:

```text
sops + age + direnv
```

- `sops` encrypts secret files.
- `age` provides the encryption key pair.
- `direnv` loads secrets only inside selected project directories.

Age private key location:

```text
~/.config/sops/age/keys.txt
```

This file must never be committed.

Create an encrypted env file:

```bash
cd ~/dotfiles
mkdir -p secrets
sops secrets/npm.sops.env
```

Example content while editing through `sops`:

```dotenv
NPM_TOKEN=real_token_here
```

After saving, the file should contain encrypted `ENC[...]` values.

Use the shell helpers for commands that need an npm token:

```bash
npm-auth publish
pnpm-auth publish
```

Example `.envrc` in a project:

```bash
use_sops_env ~/dotfiles/secrets/npm.sops.env
```

Then allow it:

```bash
direnv allow
```

## Suggested packages

Current core packages:

```text
zsh
git
micro
desktop
fcitx5
npm
pnpm
```

Good future packages:

```text
alacritty
nvim
neovide
btop
zellij
niri
waybar
wofi
wlogout
swaylock
mako
fontconfig
gtk
qt
systemd
environment
direnv
```

Avoid managing caches, login state, browser profiles, package stores, and whole IDE data directories.

## New machine bootstrap

```bash
# Arch Linux:
sudo pacman -S git stow sops age direnv

# Debian / Ubuntu:
sudo apt update
sudo apt install git stow sops age direnv

# Fedora:
sudo dnf install git stow sops age direnv

git clone https://github.com/YangYuS8/dotfiles.git ~/dotfiles
cd ~/dotfiles

./stow.sh zsh git micro
./stow.sh --apply zsh git micro
```

If encrypted secrets are needed, restore or create:

```text
~/.config/sops/age/keys.txt
```

Then test:

```bash
sops -d secrets/npm.sops.env
```

## Golden rules

1. Preview with `stow -n` before applying.
2. Stow only explicit packages.
3. Do not commit plaintext secrets.
4. Keep age private keys outside this repository.
5. Use `direnv` for project-specific environment variables.
6. Commit small, understandable changes.
