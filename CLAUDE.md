# Project Overview

macOS AI 工具套装安装脚本和文档，为 macOS 用户提供一键安装 AI 开发环境的工具。支持 Intel 和 Apple Silicon 架构，提供在线和离线两种安装方式。

## Key Files

| 文件 | 说明 |
|------|------|
| `install_ai_tools.sh` | 智能路由脚本，自动检测架构并调用对应脚本 |
| `install_ai_tools_arm64.sh` | Apple Silicon (M1/M2/M3/M4) 专用安装脚本 |
| `install_ai_tools_x86_64.sh` | Intel Mac 专用安装脚本 |
| `download_tools.sh` | 离线包下载脚本，在有网络的机器上运行 |
| `install_ai_tools_offline.sh` | 离线安装脚本，无需网络 |
| `macOS AI工具套装安装指南.md` | 手动安装步骤文档 |
| `apps/` | 离线安装资源目录 |

## Running the Scripts

### 在线安装（需网络）

```bash
./install_ai_tools.sh                 # 自动检测架构并安装
./install_ai_tools.sh --with-skills   # 含 Skills
./install_ai_tools.sh --dry-run       # 预览模式
./install_ai_tools.sh --skip-vscode   # 跳过 VSCode
./install_ai_tools.sh --skip-python   # 跳过 Python

# 或直接运行架构专用脚本
./install_ai_tools_arm64.sh           # Apple Silicon
./install_ai_tools_x86_64.sh          # Intel
```

### 离线安装（无需网络）

```bash
# 步骤 1：在有网络的机器上下载
./download_tools.sh
./download_tools.sh --arch arm64      # 仅 Apple Silicon
./download_tools.sh --arch x86_64     # 仅 Intel

# 步骤 2：将整个目录复制到目标机器
# 步骤 3：在目标机器上运行
./install_ai_tools_offline.sh
```

## Directory Structure

```
├── install_ai_tools.sh           # 智能路由脚本
├── install_ai_tools_arm64.sh     # Apple Silicon 安装
├── install_ai_tools_x86_64.sh    # Intel 安装
├── download_tools.sh             # 离线包下载
├── install_ai_tools_offline.sh   # 离线安装
├── macOS AI工具套装安装指南.md    # 手动安装文档
└── apps/                         # 离线安装资源
    ├── casks/                    # GUI 应用 (VSCode, Claude Code 等)
    │   └── {app}/{arm64,x86_64}/ # 按架构分类
    ├── vscode-extensions/        # VSCode 插件 (.vsix)
    ├── python/                   # Python wheels
    └── skills/                   # Claude Code Skills
```

## Script Architecture

安装脚本分 18 个步骤顺序执行 (v1.1):

1. Xcode Command Line Tools
2. Homebrew
3. Git
4. Node.js
5. Python3
6. **Miniconda** (新增 - 数据科学环境)
7. VSCode
8. OpenCode (使用 `anomalyco/tap/opencode`)
9. Claude Code
10. CC-Switch
11. uv
12. 数据处理工具 (pandoc, wget, jq, tree, ffmpeg)
13. Python 库 (via conda base 环境)
14. VSCode 插件
15. Skills（需 `--with-skills` 启用）
16. Document Skills (空操作，保留兼容)
17. SYSU Awesome CC（需 `--with-skills` 启用）
18. Clash Verge Rev

每个步骤都有幂等性检测：已安装的工具会自动跳过。

### 架构差异

| 项目 | Apple Silicon | Intel |
|------|---------------|-------|
| Homebrew 路径 | `/opt/homebrew` | `/usr/local` |
| 需要 PATH 配置 | 是 | 否 (默认在 PATH) |
| 脚本文件 | `install_ai_tools_arm64.sh` | `install_ai_tools_x86_64.sh` |

## Conventions

- 日志输出：`~/ai_tools_install.log`（在线）、`~/ai_tools_offline_install.log`（离线）
- 下载日志：`./download_tools.log`
- 安装标记：`~/.claude/.sysu-awesome-cc-installed`
- Skills 目录：`~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/commands/`

## Key Dependencies

- **OpenCode**: 使用 `brew install anomalyco/tap/opencode` (v1.1.44+)
  - ⚠️ 旧的 `opencode-ai/tap` 已废弃 (v0.0.55)
- **Miniconda**: 管理 Python 数据科学环境
- **VSCode 检测**: 同时检测 Homebrew 安装和 `/Applications/Visual Studio Code.app`

## Documentation Maintenance

Update this file whenever the project's directory structure changes.
