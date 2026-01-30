# Project Overview

macOS AI 工具套装安装脚本和文档，为 macOS 用户提供一键安装 AI 开发环境的工具。支持 Intel 和 Apple Silicon 架构。

## Key Files

- `install_ai_tools.sh` - 主安装脚本，自动检测已安装工具并跳过
- `macOS AI工具套装安装指南.md` - 手动安装步骤文档

## Running the Script

```bash
# 基础安装（不含 Skills）
./install_ai_tools.sh

# 完整安装（含 Skills 和 SYSU Awesome CC）
./install_ai_tools.sh --with-skills

# 预览模式（不执行）
./install_ai_tools.sh --dry-run

# 其他选项
./install_ai_tools.sh --skip-vscode     # 跳过 VSCode
./install_ai_tools.sh --skip-python     # 跳过 Python
./install_ai_tools.sh --skip-plugins    # 跳过 VSCode 插件
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
    14-16. Skills（需 `--with-skills` 启用）
14. Clash Verge Rev

每个步骤都有幂等性检测：已安装的工具会自动跳过。

## Conventions

- 日志输出到 `~/ai_tools_install.log`
- 安装标记文件：`~/.claude/.sysu-awesome-cc-installed`
- Skills 安装目录：`~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/commands/`


## Documentation Maintenance

Update this file whenever the vault's directory structure changes. You should automatically update this @CLAUDE.md file whenever the folder structure changes.
