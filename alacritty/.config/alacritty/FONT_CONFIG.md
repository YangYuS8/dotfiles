# Alacritty 字体配置说明

## 当前字体配置

### 英文字体
- **主字体**: Hack
- **样式**: Regular, Bold, Italic, Bold Italic

### 中文字体
- **回退字体**: Noto Sans CJK SC
- **配置方式**: 通过 fontconfig 自动回退

## 字体回退机制

已创建 fontconfig 配置文件：`~/.config/fontconfig/conf.d/99-alacritty-fonts.conf`

该配置确保：
1. 当 Hack 字体无法显示中文字符时，自动使用 Noto Sans CJK SC
2. 等宽字体优先级：Hack → Noto Sans Mono CJK SC → Noto Sans CJK SC

## 字体大小
- 当前字体大小：12pt
- 可在 `alacritty.toml` 中修改 `[font]` 部分的 `size` 值

## 测试字体显示

在终端中输入以下内容测试字体显示效果：

```bash
# 英文测试
echo "The quick brown fox jumps over the lazy dog"
echo "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789"

# 中文测试
echo "这是中文字体测试 - Noto Sans CJK SC"
echo "你好世界！Hello World!"

# 混合测试
echo "英文 English 123 中文测试"
```

## 调整字体大小

如果需要调整字体大小，修改 `~/.config/alacritty/alacritty.toml`：

```toml
[font]
size = 12  # 修改这个值，推荐范围：10-14
```

## 安装的字体确认

系统中已安装的相关字体：
- ✅ Hack (Regular, Bold, Italic, Bold Italic)
- ✅ Noto Sans CJK SC (多种字重)

## 常见问题

### Q: 中文显示不正常怎么办？
A: 运行 `fc-cache -fv` 重新生成字体缓存

### Q: 想换其他字体怎么办？
A: 修改 `alacritty.toml` 中的 `family` 值，使用 `fc-list` 查看可用字体

### Q: 字体太小/太大
A: 使用快捷键 `Ctrl+0` 重置字体大小，或修改配置文件中的 `size` 值

## 推荐的等宽中文字体

如果想尝试其他等宽字体组合：
- **Fira Code** + Noto Sans Mono CJK SC
- **JetBrains Mono** + Noto Sans Mono CJK SC
- **Source Code Pro** + Noto Sans Mono CJK SC
- **Cascadia Code** + Noto Sans Mono CJK SC

## 重启 Alacritty

配置已自动重新加载（`live_config_reload = true`），无需手动重启。
如果显示异常，可以完全关闭 Alacritty 后重新打开。
