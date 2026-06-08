# dotfiles 使用手册

这个仓库用来管理我的个人 dotfiles，目标是尽量适配常见 Linux 发行版，包括 Arch Linux、Debian/Ubuntu 和 Fedora。核心工具是 **GNU Stow**。

> 这个仓库只应该保存“可复现的配置”，不要保存缓存、登录状态、浏览器数据、真实 token、私钥或其它敏感信息。

## 核心原则

每个顶层目录都是一个 Stow 包。包里的目录结构要模拟 `$HOME` 下面的真实路径。

例如：

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

执行 Stow 后，家目录里会变成软链接：

```text
~/.zshrc         -> ~/dotfiles/zsh/.zshrc
~/.gitconfig     -> ~/dotfiles/git/.gitconfig
~/.config/micro  -> ~/dotfiles/micro/.config/micro
```

也就是说，之后编辑 `~/.zshrc` 和编辑 `~/dotfiles/zsh/.zshrc` 是同一回事。

## 安装工具

Arch Linux：

```bash
sudo pacman -S stow git
```

Debian / Ubuntu：

```bash
sudo apt update
sudo apt install stow git
```

Fedora：

```bash
sudo dnf install stow git
```

如果要使用加密敏感信息和项目级环境变量，再装：

Arch Linux：

```bash
sudo pacman -S sops age direnv
```

Debian / Ubuntu：

```bash
sudo apt install sops age direnv
```

Fedora：

```bash
sudo dnf install sops age direnv
```

## 应用配置

永远先预演：

```bash
cd ~/dotfiles
stow -nv -t ~ zsh
```

确认没有 conflict 后再真正执行：

```bash
stow -v -t ~ zsh
```

一次应用多个包：

```bash
cd ~/dotfiles
stow -v -t ~ zsh git micro
```

不要偷懒执行：

```bash
stow -t ~ *
```

因为 `secrets/`、文档目录或其它非配置目录不一定是 Stow 包，可能会被错误链接到家目录。

## 取消和刷新链接

取消某个包：

```bash
cd ~/dotfiles
stow -D -t ~ zsh
```

重新链接某个包：

```bash
cd ~/dotfiles
stow -R -t ~ zsh
```

## 添加已有配置文件

### 添加 `~/.gitconfig`

```bash
cd ~/dotfiles
mkdir -p git
mv ~/.gitconfig git/
stow -nv -t ~ git
stow -v -t ~ git
```

### 添加 `~/.config/alacritty`

```bash
cd ~/dotfiles
mkdir -p alacritty/.config
mv ~/.config/alacritty alacritty/.config/
stow -nv -t ~ alacritty
stow -v -t ~ alacritty
```

### 添加普通家目录文件

例如 `~/.npmrc`：

```bash
cd ~/dotfiles
mkdir -p npm
mv ~/.npmrc npm/
stow -nv -t ~ npm
stow -v -t ~ npm
```

## 修改已有配置

配置已经被 stow 管理后，下面两个命令效果一样：

```bash
nvim ~/.zshrc
nvim ~/dotfiles/zsh/.zshrc
```

修改后提交：

```bash
cd ~/dotfiles
git status
git diff
git add zsh/.zshrc
git commit -m "Update zsh config"
git push
```

## 遇到 Stow conflict 怎么办

如果看到类似：

```text
cannot stow package over existing target since neither a link nor a directory
```

说明家目录里已经有同名文件，而且不是 stow 软链接。

### 推荐处理方式一：备份旧文件

```bash
mv ~/.example ~/.example.bak
stow -nv -t ~ package
stow -v -t ~ package
```

### 推荐处理方式二：把旧文件纳入 dotfiles

```bash
cd ~/dotfiles
mkdir -p package
mv ~/.example package/
stow -nv -t ~ package
stow -v -t ~ package
```

### 慎用 `--adopt`

不要随便用：

```bash
stow --adopt
```

它会把已有目标移动进仓库。除非我非常确定它会移动什么，否则不要用。

## 哪些适合放进 dotfiles

适合：

```text
.zshrc
.zprofile
.zshenv
.p10k.zsh
.gitconfig
.config/micro
.config/alacritty
.config/nvim
.config/neovide
.config/btop
.config/zellij
.config/niri
.config/waybar
.config/wofi
.config/wlogout
.config/swaylock
.config/mako
.config/fontconfig
.config/gtk-3.0
.config/gtk-4.0
.config/qt5ct
.config/qt6ct
.config/Kvantum
.config/systemd
.config/environment.d
```

不适合：

```text
.cache
.local 整目录
.var
.rustup
.pub-cache
.gradle
.npm 整目录
.bun 整目录
.android
.java
.steam
.mozilla
.thunderbird
.pki
.gnupg
.docker
.kube
.minikube
.vscode 整目录
.cursor 整目录
.oh-my-zsh 整目录
.zsh_history
.bash_history
.zcompdump*
.viminfo
.wget-hsts
.pulse-cookie
```

重点：`.ssh`、`.gnupg`、`.pki`、`.docker`、`.kube` 这类目录默认不要进公开仓库。

## 敏感信息规则

绝对不要提交明文敏感信息：

```text
API Token
密码
私钥
SSH 私钥
GPG 私钥
npm token
.env 明文文件
Docker auth
Kubernetes kubeconfig
~/.config/sops/age/keys.txt
```

可以提交：

```text
secrets/*.sops.env    # 已经被 sops 加密的文件
.npmrc                # 只引用 ${NPM_TOKEN}，不包含真实 token
.gitconfig signingkey # 如果只是 GPG key ID 或 SSH 公钥路径，一般没问题
```

`.gitconfig` 里的 signingkey 如果是这种，通常没问题：

```ini
[user]
    signingkey = ABCD1234EF567890
```

或者：

```ini
[gpg]
    format = ssh

[user]
    signingkey = ~/.ssh/id_ed25519.pub
```

不要写成私钥路径：

```ini
[user]
    signingkey = ~/.ssh/id_ed25519
```

## 提交前检查泄露

提交前先扫一遍：

```bash
cd ~/dotfiles
grep -RniE 'npm[_-]?token|_authToken|token|secret|password|passwd|api[_-]?key|apikey|bearer|ghp_|sk-' .
```

如果在 `*.sops.env` 里看到：

```text
ENC[...]
```

这是正常的。

如果看到真实 token，立刻删掉，不要 push。

再检查 Git 状态：

```bash
git status
git diff
git diff --cached
```

## 推荐的敏感信息方案：sops + age + direnv

定位：

```text
stow   管配置链接
sops   管加密文件
age    管加密/解密钥匙
direnv 管进入项目目录时自动加载环境变量
```

最终目标：

```text
明文 token 不进 dotfiles
age 私钥不进 dotfiles
加密后的 secrets/*.sops.env 可以进 Git
项目需要什么 token，就在项目 .envrc 里按需加载
```

## 配置 age 密钥

生成密钥：

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

查看公钥：

```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

输出的 `age1...` 是公钥，可以写进 `.sops.yaml`。

`~/.config/sops/age/keys.txt` 里的 `AGE-SECRET-KEY-...` 是私钥，绝对不能上传。

## 创建 `.sops.yaml`

在仓库根目录：

```bash
cd ~/dotfiles
nvim .sops.yaml
```

内容示例：

```yaml
creation_rules:
  - path_regex: secrets/.*\.sops\.env$
    age: age1你的公钥
```

## 创建加密 secret 文件

例如 npm token：

```bash
cd ~/dotfiles
mkdir -p secrets
sops secrets/npm.sops.env
```

在 sops 编辑器里写：

```dotenv
NPM_TOKEN=真实token
```

保存退出后，文件应该变成加密内容。检查：

```bash
cat secrets/npm.sops.env
```

如果看到真实 token，说明没加密成功，不能提交。

正确状态应该类似：

```text
NPM_TOKEN=ENC[AES256_GCM,data:...]
sops_age__list_0__map_enc=...
sops_mac=...
```

测试解密：

```bash
sops -d secrets/npm.sops.env
```

## `.npmrc` 的正确写法

不要把真实 token 写进 `.npmrc`。

`~/dotfiles/npm/.npmrc` 应该写：

```ini
//registry.npmjs.org/:_authToken=${NPM_TOKEN}
```

然后：

```bash
cd ~/dotfiles
stow -nv -t ~ npm
stow -v -t ~ npm
```

真实 `NPM_TOKEN` 由 sops + direnv 提供。

## 配置 direnv

创建：

```bash
cd ~/dotfiles
mkdir -p direnv/.config/direnv
nvim direnv/.config/direnv/direnvrc
```

写入：

```bash
use_sops_env() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "missing sops env file: $file" >&2
    return 1
  fi

  if ! command -v sops >/dev/null 2>&1; then
    echo "sops not found" >&2
    return 1
  fi

  eval "$(sops -d "$file" | direnv dotenv bash /dev/stdin)"
}
```

链接：

```bash
cd ~/dotfiles
stow -nv -t ~ direnv
stow -v -t ~ direnv
```

在 `~/dotfiles/zsh/.zshrc` 末尾加入：

```bash
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
```

重新加载：

```bash
source ~/.zshrc
```

## 在项目里加载 secret

进入项目：

```bash
cd ~/Code/some-project
nvim .envrc
```

写：

```bash
use_sops_env ~/dotfiles/secrets/npm.sops.env
```

授权：

```bash
direnv allow
```

进入项目目录时，`NPM_TOKEN` 会自动出现；离开项目目录后，变量会自动卸载。

## 临时命令使用 secret

如果只想给某个命令临时使用 token：

```bash
sops exec-env ~/dotfiles/secrets/npm.sops.env 'npm publish'
```

AI 工具也可以这样：

```bash
sops exec-env ~/dotfiles/secrets/ai.sops.env 'opencode'
```

## 推荐 secret 分类

```text
secrets/
├── global.sops.env   # 极少数全局变量
├── npm.sops.env      # NPM_TOKEN
├── github.sops.env   # GITHUB_TOKEN / GH_TOKEN
├── ai.sops.env       # OPENAI / GEMINI / ANTHROPIC 等
├── cnb.sops.env      # CNB 相关
└── deploy.sops.env   # 部署相关
```

不要把所有 token 都塞进一个超大文件。项目需要什么，就加载什么。

## `.gitignore` 建议

```gitignore
# system/editor junk
.DS_Store
*.swp
*.swo
*.tmp
*.log
*.cache

# shell state
.zsh_history
.bash_history
.zcompdump*
*.zwc

# backups
*.bak
*.backup

# plaintext secrets
.env
.env.*
*.local
*.secret
*.token
*.key
private/
.config/private/

# age private key must never enter repo
.config/sops/age/keys.txt
sops/age/keys.txt

# allow encrypted sops env files
!secrets/*.sops.env
```

注意：`.gitignore` 只对未跟踪文件有效。已经 `git add` 过的文件不会因为 `.gitignore` 自动消失。

## 新机器恢复流程

```bash
# Arch Linux：
sudo pacman -S git stow sops age direnv

# Debian / Ubuntu：
sudo apt update
sudo apt install git stow sops age direnv

# Fedora：
sudo dnf install git stow sops age direnv

git clone https://github.com/YangYuS8/dotfiles.git ~/dotfiles
cd ~/dotfiles

stow -nv -t ~ zsh git micro
stow -v -t ~ zsh git micro
```

如果要解密 secrets，需要恢复：

```text
~/.config/sops/age/keys.txt
```

然后测试：

```bash
sops -d secrets/npm.sops.env
```

## 多设备同步 secrets

第二台机器生成自己的 age key：

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

拿到新的 `age1...` 公钥。

在主机器的 `.sops.yaml` 里追加 recipient：

```yaml
creation_rules:
  - path_regex: secrets/.*\.sops\.env$
    age: >-
      age1主机器公钥,
      age1第二台机器公钥
```

更新已有文件：

```bash
sops updatekeys secrets/npm.sops.env
sops updatekeys secrets/github.sops.env
sops updatekeys secrets/ai.sops.env
```

## 最重要的规则

1. 每次 `stow` 前先 `-n` 预演。
2. 只 stow 明确包名，不要 `stow *`。
3. 明文 token 永远不进仓库。
4. `~/.config/sops/age/keys.txt` 永远不进仓库。
5. `secrets/*.sops.env` 可以进 Git，但必须确认已经加密。
6. 项目专用 token 用 `direnv` 加载，不要全塞进 `.zshrc`。
7. `.zshrc` 只放通用配置，不放真实密钥。
8. 提交前 `grep` 扫一遍敏感词。
9. commit 要小，不要一次塞一堆无关配置。
10. dotfiles 是“可复现配置”，不是“整个家目录备份”。
