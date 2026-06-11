# Niri + Noctalia 配置说明

此配置文件已根据 Noctalia 官方文档（docs.noctalia.dev）优化。

## 主要特性

### 🎯 核心功能快捷键

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `MOD+Space` | 应用启动器 | 打开 Noctalia 应用启动器 |
| `MOD+S` | 控制中心 | 打开系统控制中心 |
| `MOD+,` | 设置 | 打开 Noctalia 设置 |
| `MOD+Return` | 终端 | 启动 Alacritty 终端 |
| `MOD+B` | 浏览器 | 启动 Firefox |
| `MOD+E` | 文件管理器 | 启动 Nautilus |
| `MOD+L` | 锁屏 | 锁定屏幕 |

### 🚀 快速访问

| 快捷键 | 功能 |
|--------|------|
| `MOD+V` | 剪贴板历史 |
| `MOD+=` | 计算器 |
| `MOD+D` | 日历 |
| `MOD+X` | 会话菜单（注销/重启/关机） |

### 🎵 媒体控制

- **音量**：`XF86AudioRaiseVolume` / `XF86AudioLowerVolume` / `XF86AudioMute`
- **麦克风**：`XF86AudioMicMute` / `MOD+Shift+↑` / `MOD+Shift+↓`
- **播放控制**：`XF86AudioPlay` / `XF86AudioNext` / `XF86AudioPrev`

### 📸 截图与录屏

| 快捷键 | 功能 |
|--------|------|
| `Print` | 截图（选择区域） |
| `MOD+Print` | 截图（当前屏幕） |
| `MOD+Shift+S` | 截图（当前窗口） |
| `MOD+R` | 开始/停止屏幕录制 |

### 💡 系统控制

| 快捷键 | 功能 |
|--------|------|
| `XF86MonBrightnessUp/Down` | 亮度控制 |
| `MOD+N` | 通知历史 |
| `MOD+Shift+N` | 勿扰模式 |
| `MOD+Ctrl+N` | 清除所有通知 |
| `MOD+I` | 空闲抑制器（防止休眠） |

### 🎨 外观控制

| 快捷键 | 功能 |
|--------|------|
| `MOD+Shift+T` | 切换深色/浅色主题 |
| `MOD+Shift+W` | 壁纸选择器 |
| `MOD+Shift+B` | 切换顶栏可见性 |

### 🪟 窗口管理

#### 焦点控制
- `MOD+方向键` 或 `MOD+H/J/K/L`：移动焦点
- `MOD+Ctrl+方向键`：移动窗口

#### 工作区
- `MOD+1-9`：切换到工作区 1-9
- `MOD+Ctrl+1-9`：移动窗口到工作区
- `MOD+Tab`：切换到上一个工作区
- `MOD+O`：概览模式

#### 布局
- `MOD+[` / `MOD+]`：调整列宽度
- `MOD+Shift+[` / `MOD+Shift+]`：调整窗口高度
- `MOD+C`：居中列
- `MOD+T`：切换浮动窗口
- `MOD+F`：全屏
- `MOD+W`：切换标签显示

## 壁纸和概览设置

配置文件中提供了三种壁纸/概览方案：

### 选项 1：模糊概览壁纸（当前启用）
- 在概览模式下显示模糊和变暗的壁纸
- 需要在 Noctalia 设置中启用"概览壁纸"
- 使用更多内存（每个显示器一张额外壁纸）

### 选项 2：固定壁纸
- 壁纸始终可见，不随工作区滚动
- 需要在 Noctalia 设置中禁用"概览壁纸"
- 取消配置中相应部分的注释即可使用

### 选项 3：纯色概览
- 简洁的纯色背景
- 适合注重生产力的用户
- 取消配置中相应部分的注释即可使用

## 启动程序

配置会自动启动以下程序：
1. Polkit 认证代理（权限管理）
2. SWWW 壁纸守护进程
3. 默认壁纸
4. Noctalia Shell

## 注意事项

1. **MOD 键**：默认为 `Super`（Windows 键）
2. **快捷键冲突**：某些快捷键可能与您的应用冲突，可以根据需要调整
3. **重新加载配置**：修改配置后，Niri 会自动重新加载

## 相关资源

- [Noctalia 官方文档](https://docs.noctalia.dev/)
- [Niri Wiki](https://github.com/YaLTeR/niri/wiki)
- [Noctalia GitHub](https://github.com/noctalia-dev)
- [Noctalia Discord](https://discord.noctalia.dev/)

## 自定义

您可以根据个人喜好自定义：
- 修改快捷键绑定
- 调整窗口间隙和圆角
- 更改动画效果
- 添加自己的启动程序
- 设置特定应用的窗口规则

享受您的 Niri + Noctalia 体验！🎉
