# 🤖 macOS AI 工具套装安装脚本

一键安装 macOS AI 开发环境的自动化工具，支持 Intel 和 Apple Silicon 架构。

## ✨ 特性

- 🔄 **智能架构检测**：自动识别 Intel / Apple Silicon 并调用对应脚本
- 📦 **在线 + 离线安装**：支持有网络和无网络环境
- ⚡ **幂等性设计**：已安装的工具自动跳过，可重复运行
- 🛠️ **完整工具链**：从基础开发环境到 AI 编程助手一站式安装

## 📋 安装内容

| 类别 | 工具 |
|------|------|
| 基础环境 | Xcode CLT, Homebrew, Git, Node.js, Python3 |
| 数据科学 | Miniconda + Python 数据科学包 |
| AI 编程 | Claude Code, OpenCode, CC-Switch |
| 开发工具 | VSCode + 插件, uv |
| 命令行工具 | pandoc, wget, jq, tree, ffmpeg |

### 🐍 Python 包（Miniconda base 环境）

| 包名 | 说明 |
|------|------|
| `pandas` | 数据分析 |
| `numpy` | 数值计算 |
| `matplotlib` | 数据可视化 |
| `scipy` | 科学计算 |
| `openpyxl` | Excel 读写 (.xlsx) |
| `xlrd` | Excel 读取 (.xls) |
| `jupyter` | Jupyter Notebook |
| `markitdown` | 文件转 Markdown |

### 🛠️ 命令行工具

| 工具 | 说明 |
|------|------|
| `pandoc` | 文档格式转换 |
| `wget` | 文件下载 |
| `jq` | JSON 处理 |
| `tree` | 目录树显示 |
| `ffmpeg` | 音视频处理 |
| 网络工具 | Clash Verge Rev |

### 🔌 VSCode 插件

#### Markdown 编辑与预览

| 插件 | 说明 |
|------|------|
| `shd101wyy.markdown-preview-enhanced` | 强大的 Markdown 预览，支持导出 PDF/HTML/PNG、数学公式、流程图 |
| `yzhang.markdown-all-in-one` | 全方位 Markdown 编辑支持：自动完成、列表编辑、表格格式化 |
| `yzane.markdown-pdf` | 将 Markdown 转换为 PDF |
| `marp-team.marp-vscode` | Marp 幻灯片制作，用 Markdown 写演示文稿 |

#### 文档与数据

| 插件 | 说明 |
|------|------|
| `cweijan.vscode-office` | 预览 Word (.docx)、Excel (.xlsx)、PDF 等 Office 文档 |
| `ms-toolsai.datawrangler` | 数据整理工具，可视化处理表格数据 |
| `James-Yu.latex-workshop` | LaTeX 编辑支持，论文写作必备 |

#### Git 工具

| 插件 | 说明 |
|------|------|
| `mhutchie.git-graph` | Git 图形化历史，可视化查看分支和提交 |

### 🎯 Claude Code 推荐 Skills

自动安装到 `~/.claude/skills/`：

| Skill | 说明 |
|-------|------|
| `arxiv` | arXiv 论文搜索 |
| `cc-insights` | Claude Code 使用分析 |
| `chinese-quote-converter` | 中英文引号转换 |
| `command-development` | 自定义命令开发 |
| `docx` | Word 文档操作 |
| `fetch4ai` | 网页抓取 (crawl4ai) |
| `frontend-design` | 前端界面设计 |
| `markitdown` | 文件转 Markdown |
| `marp-slides-creator` | Marp 幻灯片生成 |
| `md-to-docx` | Markdown 转 Word |
| `pdf` | PDF 操作 |
| `pptx` | PowerPoint 操作 |
| `skill-creator` | Skill 创建指南 |
| `web-research` | 网络研究 |
| `xlsx` | Excel 操作 |

### 📦 可选 Skills（需 `--with-skills`）

| Skill | 说明 |
|-------|------|
| Document Skills | Anthropic 官方文档处理插件 |
| SYSU Awesome CC | 中大 Claude Code 扩展集合 |

## 🚀 快速开始

### 在线安装（推荐）

```bash
# 克隆仓库
git clone https://github.com/Xueheng-Li/ai-tools-installation.git
cd ai-tools-installation

# 运行安装脚本（自动检测架构）
./install_ai_tools.sh
```

### 安装选项

```bash
./install_ai_tools.sh                 # 标准安装
./install_ai_tools.sh --with-skills   # 包含额外 Skills
./install_ai_tools.sh --dry-run       # 预览模式（不实际安装）
./install_ai_tools.sh --skip-vscode   # 跳过 VSCode
./install_ai_tools.sh --skip-python   # 跳过 Python
```

### 离线安装

适用于无法联网的机器：

```bash
# 步骤 1：在有网络的机器上下载离线包
./download_tools.sh
./download_tools.sh --arch arm64      # 仅下载 Apple Silicon 版本
./download_tools.sh --arch x86_64     # 仅下载 Intel 版本

# 步骤 2：将整个目录复制到目标机器（U盘、AirDrop 等）

# 步骤 3：在目标机器上运行离线安装
./apps/install_ai_tools_offline.sh
```

## 📁 目录结构

```
├── install_ai_tools.sh           # 智能路由脚本（入口）
├── install_ai_tools_arm64.sh     # Apple Silicon 安装脚本
├── install_ai_tools_x86_64.sh    # Intel 安装脚本
├── download_tools.sh             # 离线包下载脚本
├── macOS AI工具套装安装指南.md    # 手动安装文档
├── recommended_skills/           # 推荐的 Claude Code Skills
└── apps/                         # 离线安装资源
    ├── install_ai_tools_offline.sh
    ├── casks/                    # GUI 应用安装包
    ├── vscode-extensions/        # VSCode 插件
    ├── python/                   # Python wheels
    └── skills/                   # Claude Code Skills
```

## 💻 系统要求

- macOS 10.15 (Catalina) 或更高版本
- 管理员权限（部分工具需要 sudo）
- 约 5GB 可用磁盘空间

## 📝 日志文件

- 在线安装日志：`~/ai_tools_install.log`
- 离线安装日志：`~/ai_tools_offline_install.log`
- 下载日志：`./download_tools.log`

## ✅ 验证安装

安装完成后，运行以下命令验证：

```bash
# 基础工具
brew --version && git --version && node --version

# AI 编程助手
claude --version && opencode --version

# Python 环境
python3 --version && conda --version && uv --version

# 数据处理
pandoc --version && ffmpeg -version
```

## 🎯 下一步

1. 执行 `source ~/.zshrc` 或重启终端使配置生效
2. 打开 **CC-Switch** 应用配置 API 密钥，或运行 `claude login` 登录
3. 运行 `opencode` 或 `claude` 开始使用 AI 编程助手
4. 使用 `conda activate base` 激活数据科学环境

## 🔧 常见问题

### Q: 安装中断了怎么办？
A: 直接重新运行脚本即可，已安装的工具会自动跳过。

### Q: 如何只安装部分工具？
A: 使用 `--skip-vscode` 或 `--skip-python` 等选项跳过特定工具。

### Q: Apple Silicon 和 Intel 有什么区别？
A: 主要是 Homebrew 安装路径不同：
- Apple Silicon: `/opt/homebrew`
- Intel: `/usr/local`

### Q: Claude Code 登录问题？
A: 运行 `claude login` 后会打开浏览器登录 Anthropic 账号，或使用 `ANTHROPIC_API_KEY` 环境变量配置 API 密钥。

### Q: 如何手动安装 Skills？
A: 有三种方式：
```bash
# 方式 1：npx skills（推荐）
npx skills add anthropics/skills --all

# 方式 2：Claude Code 内置命令
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills

# 方式 3：使用 CC-Switch 图形界面
```

## 📚 相关资源

- [Claude Code 文档](https://docs.anthropic.com/en/docs/claude-code)
- [Anthropic 官方 Skills](https://github.com/anthropics/skills)
- [Skills 目录 (skills.sh)](https://skills.sh)
- [OpenCode 官网](https://opencode.ai/)
- [CC-Switch](https://github.com/farion1231/cc-switch)
- [Miniconda 文档](https://docs.anaconda.com/miniconda/)

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！
