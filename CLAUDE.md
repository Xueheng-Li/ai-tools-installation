# Project Overview

macOS AI 工具套装安装脚本和文档，为 macOS 用户提供一键安装 AI 开发环境的工具。支持 Intel 和 Apple Silicon 架构，提供在线和离线两种安装方式。

## Key Files

| 文件 | 说明 |
|------|------|
| `install_ai_tools.sh` | 在线安装脚本，自动检测已安装工具并跳过 |
| `download_tools.sh` | 离线包下载脚本，在有网络的机器上运行 |
| `install_ai_tools_offline.sh` | 离线安装脚本，无需网络 |
| `macOS AI工具套装安装指南.md` | 手动安装步骤文档 |
| `apps/` | 离线安装资源目录 |

## Running the Scripts

### 在线安装（需网络）

```bash
./install_ai_tools.sh                 # 基础安装
./install_ai_tools.sh --with-skills   # 含 Skills
./install_ai_tools.sh --dry-run       # 预览模式
./install_ai_tools.sh --skip-vscode   # 跳过 VSCode
./install_ai_tools.sh --skip-python   # 跳过 Python
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
├── install_ai_tools.sh           # 在线安装
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

安装脚本分 17 个步骤顺序执行：

1. Xcode Command Line Tools
2. Homebrew
3. Git
4. Node.js
5. Python3
6. VSCode
7. OpenCode
8. Claude Code
9. CC-Switch
10. uv
11. 数据处理工具 (pandoc, wget, jq, tree, ffmpeg)
12. Python 库 (pandas, numpy, matplotlib 等)
13. VSCode 插件
14. Skills（需 `--with-skills` 启用）
15. Clash Verge Rev

每个步骤都有幂等性检测：已安装的工具会自动跳过。

## Conventions

- 日志输出：`~/ai_tools_install.log`（在线）、`~/ai_tools_offline_install.log`（离线）
- 下载日志：`./download_tools.log`
- 安装标记：`~/.claude/.sysu-awesome-cc-installed`
- Skills 目录：`~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/commands/`

## Documentation Maintenance

Update this file whenever the project's directory structure changes.
