---
created: 2026-01-29
tags:
  - type/reference
  - status/active
aliases: [AI工具安装, macOS开发环境搭建]
---

# macOS AI 工具套装安装指南

为学校领导 Mac 电脑安装完整 AI 开发环境的步骤说明。本指南适用于 macOS (Intel 和 Apple Silicon)。

## 前置准备

打开终端应用 (`Terminal.app`)

## 1. VSCode

从官网下载安装包：

1. 访问 https://code.visualstudio.com/
2. 下载 macOS 版本（自动识别芯片类型）
3. 双击 `.dmg` 文件拖拽到 Applications 文件夹
4. 启动 VSCode，完成首次设置

## 2. Homebrew

Homebrew 是 macOS 最流行的包管理器，后续所有命令行工具都通过它安装。

**注意**：Homebrew 不需要完整的 Xcode IDE，但需要 Xcode Command Line Tools（轻量级编译工具包，约 1GB）。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

如果安装过程中提示需要 Command Line Tools，运行：

```bash
xcode-select --install
```

安装完成后根据终端提示，将 Homebrew 添加到 PATH（如果提示的话）。通常需要运行：

```bash
# Apple Silicon (M1/M2/M3/M4)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel（macOS 默认使用 zsh）
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

验证安装：

```bash
brew --version
```

## 3. Git

macOS 自带 Git，但通过 Homebrew 安装可获得最新版本。

```bash
# 安装 Git（如果需要 Xcode Command Line Tools，Homebrew 会提示）
brew install git

# 验证版本
git --version

# 配置基本信息（替换为领导姓名和邮箱）
git config --global user.name "领导姓名"
git config --global user.email "领导邮箱"
```

如果遇到权限问题，先安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

## 4. OpenCode

OpenCode 是开源 AI 编程助手（Go 语言编写），可在终端中直接使用。

```bash
# 方法 1：使用安装脚本（推荐）
curl -fsSL https://raw.githubusercontent.com/opencode-ai/opencode/refs/heads/main/install | bash

# 方法 2：使用 Homebrew
brew install opencode-ai/tap/opencode

# 方法 3：使用 Go（如果已安装 Go）
go install github.com/opencode-ai/opencode@latest

# 验证安装
opencode --version
```

首次使用需要配置 API 密钥。OpenCode 支持多种 AI 模型提供商，包括 Anthropic、OpenAI 等。

OpenCode 兼容 Claude Code 的 Skills 格式，会自动读取 `~/.claude/skills/` 目录。使用 CC-Switch 安装的 Skills 两个工具都能用。

## 5. Node.js

Node.js 是 JavaScript 运行时，Claude Code 和许多 AI 工具依赖它。

```bash
# 安装 Node.js（包含 npm 包管理器）
brew install node

# 验证安装
node --version
npm --version
```

## 6. Claude Code

Claude Code 是 Anthropic 官方 AI 编程助手，功能强大的终端 AI 工具。

```bash
# 安装 Claude Code（via brew）
brew install --cask claude-code

# 验证安装
claude --version
```

首次使用需要 Anthropic API 密钥或通过 `claude login` 登录 Anthropic 账号。

### 安装 Anthropic 官方 Skills

Skills 是 Claude Code 的扩展能力包，可以增强特定任务的表现。

- **官方仓库**: https://github.com/anthropics/skills
- **Skills 目录**: https://skills.sh

**方法 1：使用 npx skills（推荐）**

Vercel 出品的 Skills 包管理器，支持 32 种 AI 工具，一条命令搞定。

```bash
# 安装 Anthropic 官方 Skills（会提示选择要安装的 Skills）
npx skills add anthropics/skills

# 安装到所有工具，跳过确认
npx skills add anthropics/skills --all

# 只安装到 Claude Code 和 OpenCode
npx skills add anthropics/skills -a claude-code -a opencode

# 全局安装（用户目录）
npx skills add anthropics/skills -g

# 查看已安装的 Skills
npx skills list
```

**方法 2：使用 Claude Code 内置命令**

```bash
# 在 Claude Code 中注册 Anthropic 官方 Skills 仓库
/plugin marketplace add anthropics/skills

# 安装文档处理 Skills（Word、PDF、PPT、Excel）
/plugin install document-skills@anthropic-agent-skills
```

**方法 3：使用 CC-Switch 图形界面**

CC-Switch 是 Claude Code 的图形化管理工具，适合不喜欢命令行的用户。

```bash
# 安装 CC-Switch
brew tap farion1231/ccswitch
brew install --cask cc-switch

# 更新 CC-Switch
brew upgrade --cask cc-switch
```

安装后打开 CC-Switch 应用：
1. 点击右上角 Skills 按钮
2. 浏览预配置的 GitHub 仓库（包含 Anthropic 官方 Skills）
3. 点击 Install 一键安装到 `~/.claude/skills/`

CC-Switch 还支持：
- 多 API 配置一键切换
- 同时管理 Claude Code、OpenCode、Gemini CLI
- 自定义 Skills 仓库

## 7. VSCode 插件

打开 VSCode，按 `Cmd + Shift + X` 打开插件市场，搜索并安装以下插件：

### Markdown 编辑与预览

- **Markdown Preview Enhanced** (`shd101wyy.markdown-preview-enhanced`)
  - 强大的 Markdown 预览，支持导出 PDF、HTML、PNG
  - 支持数学公式、流程图、代码高亮
  - 预览：点击右上角预览按钮

- **Markdown All in One** (`yzhang.markdown-all-in-one`)
  - 全方位 Markdown 编辑支持
  - 自动完成、列表编辑、表格格式化

- **Markdown PDF** (`yzane.markdown-pdf`)
  - 将 Markdown 转换为 PDF

### Office 文档预览

- **Office Viewer** (`cweijan.vscode-office`)
  - 预览 Word (`.docx`)
  - 预览 Excel (`.xls`, `.xlsx`, `.csv`)
  - 预览 PDF (`.pdf`)
  - 支持直接在 VSCode 中查看和编辑

安装后，点击 `.docx` 或 `.xlsx` 文件会自动在 VSCode 内部预览。

## 8. 数据处理工具

### Python

```bash
# 安装 Python 3（Homebrew 默认安装最新版）
brew install python3

# 验证安装
python3 --version
pip3 --version
```

### Python 数据分析库

```bash
# 安装核心数据处理库
pip3 install pandas numpy matplotlib

# 安装其他常用库（根据需要）
pip3 install scipy openpyxl xlrd  # Excel 处理
pip3 install jupyter  # Jupyter Notebook
```

### uv（现代 Python 包管理器）

uv 是 Rust 编写的 Python 包管理器，比 pip 快 10-100 倍。

```bash
# 安装 uv
brew install uv

# 验证安装
uv --version

# 使用示例（替代 pip）
uv pip install pandas
uv pip install -r requirements.txt
```

### Pandoc

Pandoc 是万能文档转换工具，支持 Markdown、Word、PDF、LaTeX 等格式互转。

```bash
# 安装 Pandoc
brew install pandoc

# 验证安装
pandoc --version

# 示例：将 Markdown 转换为 Word
pandoc input.md -o output.docx

# 示例：将 Word 转换为 Markdown
pandoc input.docx -o output.md
```

### 其他实用工具

```bash
# 安装 wget（命令行下载工具）
brew install wget

# 安装 jq（JSON 处理工具）
brew install jq

# 安装 tree（目录树显示工具）
brew install tree

# 安装 ffmpeg（音视频处理工具）
brew install ffmpeg
```

ffmpeg 用于音视频格式转换、提取音频、压缩视频等，很多 AI 工具处理多媒体时需要它。

## 9. ClashX Pro（网络代理工具）

ClashX Pro 是 macOS 下的代理客户端，使用 Clash Premium 内核，支持 SS、SSR、V2Ray、Trojan 等协议。在国内访问 GitHub、npm 等服务时可能需要。

### 安装方式

**方法 1：Homebrew 安装（推荐）**

```bash
# 安装 ClashX Pro
brew install --cask clashx-pro

# 或安装标准版 ClashX
brew install --cask clashx

# 或安装 Clash Verge Rev（仍在更新的替代品）
brew install --cask clash-verge-rev
```

**方法 2：手动下载安装**

由于 Clash 删库事件，原 GitHub 仓库已不可用。可从以下备份站点下载：

- 备份下载站: https://clashxpro.org/clashx-pro-download/
- ClashX.Meta (替代版本): https://github.com/MetaCubeX/ClashX.Meta

下载 `.dmg` 文件后：

1. 双击 `ClashX Pro.dmg`
2. 将 `ClashX Pro.app` 拖入 Applications 文件夹

**首次启动**会提示安装辅助程序，点击"安装"并输入系统密码

### 配置订阅

1. 点击菜单栏 ClashX Pro 图标
2. 选择「配置」→「托管配置」→「管理」
3. 点击「添加」，输入服务商提供的订阅地址
4. 点击「确定」下载配置

### 启用代理

1. 在菜单栏图标中选择「Proxy」，选择合适的节点
2. 点击「设置为系统代理」开启全局代理
3. 或选择「增强模式」实现更智能的分流

### 终端代理设置

ClashX Pro 默认监听 `127.0.0.1:7890`，在终端中临时启用代理：

```bash
# 临时设置代理（当前终端会话有效）
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890

# 取消代理
unset https_proxy http_proxy all_proxy
```

如需永久生效，可添加到 `~/.zshrc`（但建议只在需要时手动开启）。

### 替代方案

ClashX Pro 已停止更新，仅支持 macOS 15 Sequoia 及以下版本。如遇兼容性问题，可考虑：

- **Clash Verge Rev**: https://github.com/clash-verge-rev/clash-verge-rev（跨平台，仍在更新）
- **ClashX.Meta**: https://github.com/MetaCubeX/ClashX.Meta（社区维护版本）

## 10. AI 工具配置（可选）

OpenCode 和 Claude Code 都是终端工具，会调用系统安装的命令行工具。确保 Python、Pandoc、ffmpeg 等在 PATH 中即可：

```bash
# 验证各工具可被调用
python3 --version
pandoc --version
ffmpeg -version
uv --version
```

## 11. 验证安装

在终端运行以下命令验证所有工具已正确安装：

```bash
# VSCode（手动检查应用是否在 Applications 文件夹）
code --version

# Homebrew
brew --version

# Git
git --version

# Node.js
node --version
npm --version

# AI 编程助手
opencode --version
claude --version

# Python 环境
python3 --version
uv --version
pip3 list | grep pandas

# 文档和多媒体处理
pandoc --version
ffmpeg -version
```

## 12. VSCode 设置建议

在 VSCode 中按 `Cmd + ,` 打开设置，建议调整以下选项：

```json
{
  // 默认编辑器设置
  "editor.fontSize": 14,
  "editor.tabSize": 2,
  "editor.wordWrap": "on",
  "editor.formatOnSave": true,

  // Markdown 设置
  "markdown.preview.fontSize": 16,
  "markdown.preview.lineHeight": 1.6
}
```

注：Office Viewer 插件的设置可在 VSCode 设置中搜索 "office" 查看可用选项。

## 13. 常见问题

### Homebrew 安装失败

确保网络连接正常，如果遇到网络问题，可以尝试使用国内镜像源。

### Python 版本问题

自 macOS 12.3 (Monterey) 起，系统不再预装 Python。必须通过 Homebrew 安装 Python 3，使用 `python3` 命令。

### VSCode 插件无法安装

检查网络连接，或手动从 VSCode 插件官网下载 `.vsix` 文件离线安装。

### AI 工具无法调用 Python

确保 Python 在 PATH 中，在终端运行 `which python3` 应该返回路径（如 `/opt/homebrew/bin/python3`）。

### Claude Code 登录问题

运行 `claude login` 后会打开浏览器登录 Anthropic 账号，或使用 `ANTHROPIC_API_KEY` 环境变量配置 API 密钥。

## 完成清单

- [ ] VSCode 安装完成并启动
- [ ] Homebrew 安装完成并验证
- [ ] Git 安装完成并配置基本信息
- [ ] Node.js 和 npm 安装完成
- [ ] OpenCode 安装完成并验证
- [ ] Claude Code 安装完成并验证
- [ ] CC-Switch 安装完成（可选）
- [ ] Anthropic 官方 Skills 安装完成
- [ ] VSCode 插件（Markdown Preview Enhanced、Office Viewer 等）安装完成
- [ ] Python 3 和 uv 安装完成
- [ ] Pandas 等数据分析库安装完成
- [ ] Pandoc 安装完成并验证
- [ ] ffmpeg 安装完成并验证
- [ ] ClashX Pro 安装完成（可选，按需安装）
- [ ] 所有工具版本验证通过

## 下一步

安装完成后，可以开始使用这些工具：
- 使用 VSCode 编辑 Markdown、查看 Office 文档
- 使用 OpenCode 或 Claude Code 进行 AI 辅助编程
- 使用 Claude Code Skills 处理 Word、PDF、PPT、Excel 文档
- 使用 Python 和 Pandas 处理数据（用 uv 加速安装）
- 使用 Pandoc 进行文档格式转换
- 使用 ffmpeg 处理音视频文件

## Related

- [[同步Mac间Claude Code配置]] - 如果领导需要在多台 Mac 间同步配置
- [[Git Worktree使用指南]] - Git 高级用法

## Source

- VSCode 官网: https://code.visualstudio.com/
- Homebrew 官网: https://brew.sh/
- Node.js 官网: https://nodejs.org/
- OpenCode 官网: https://opencode.ai/
- OpenCode GitHub: https://github.com/opencode-ai/opencode
- Claude Code 文档: https://docs.anthropic.com/en/docs/claude-code
- Anthropic 官方 Skills: https://github.com/anthropics/skills
- Skills 目录 (skills.sh): https://skills.sh
- npx skills (Vercel): https://github.com/vercel-labs/skills
- CC-Switch: https://github.com/farion1231/cc-switch
- uv 文档: https://docs.astral.sh/uv/
- Pandoc 官网: https://pandoc.org/
- ffmpeg 官网: https://ffmpeg.org/
- ClashX Pro 下载: https://clashxpro.org/clashx-pro-download/
- Clash Verge Rev: https://github.com/clash-verge-rev/clash-verge-rev
- ClashX.Meta: https://github.com/MetaCubeX/ClashX.Meta

---

*Created: 2026-01-29*
*适用于 macOS (Intel 和 Apple Silicon)*
