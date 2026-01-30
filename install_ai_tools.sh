#!/bin/bash
#
# macOS AI 工具套装一键安装脚本 v1.1 (智能路由版)
# 作者: Claude Code for Professor Xueheng Li
# 日期: 2026-01-30
#
# 此脚本自动检测 Mac 架构并调用对应的安装脚本:
#   - Apple Silicon (arm64) → install_ai_tools_arm64.sh
#   - Intel (x86_64) → install_ai_tools_x86_64.sh
#
# 用法: ./install_ai_tools.sh [选项]
#   所有选项将传递给架构专用脚本
#   --skip-vscode     跳过 VSCode 安装
#   --skip-python     跳过 Python 相关安装
#   --with-skills     安装 Skills (默认跳过)
#   --skip-plugins    跳过 VSCode 插件安装
#   --dry-run         只显示将要执行的操作，不实际执行
#   --help            显示帮助信息

set -e

# ══════════════════════════════════════════════════════════════
# 颜色定义
# ══════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ══════════════════════════════════════════════════════════════
# 获取脚本所在目录
# ══════════════════════════════════════════════════════════════

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ══════════════════════════════════════════════════════════════
# 架构检测与脚本选择
# ══════════════════════════════════════════════════════════════

detect_and_run() {
    local ARCH=$(uname -m)
    local TARGET_SCRIPT=""

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}           macOS AI 工具套装一键安装脚本 v1.1                 ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$ARCH" == "arm64" ]]; then
        echo -e "${GREEN}[检测]${NC} 系统架构: ${BOLD}Apple Silicon (arm64)${NC}"
        TARGET_SCRIPT="$SCRIPT_DIR/install_ai_tools_arm64.sh"
    elif [[ "$ARCH" == "x86_64" ]]; then
        echo -e "${GREEN}[检测]${NC} 系统架构: ${BOLD}Intel (x86_64)${NC}"
        TARGET_SCRIPT="$SCRIPT_DIR/install_ai_tools_x86_64.sh"
    else
        echo -e "${RED}[错误]${NC} 不支持的架构: $ARCH"
        echo "  本脚本仅支持 Apple Silicon (arm64) 和 Intel (x86_64) Mac"
        exit 1
    fi

    # 检查目标脚本是否存在
    if [[ ! -f "$TARGET_SCRIPT" ]]; then
        echo -e "${RED}[错误]${NC} 找不到架构专用脚本: $TARGET_SCRIPT"
        echo ""
        echo "请确保以下文件存在于同一目录:"
        echo "  - install_ai_tools_arm64.sh   (Apple Silicon)"
        echo "  - install_ai_tools_x86_64.sh  (Intel)"
        exit 1
    fi

    # 确保脚本可执行
    chmod +x "$TARGET_SCRIPT"

    echo -e "${BLUE}[执行]${NC} 运行: $(basename "$TARGET_SCRIPT")"
    echo ""

    # 执行目标脚本，传递所有参数
    exec "$TARGET_SCRIPT" "$@"
}

# ══════════════════════════════════════════════════════════════
# 主入口
# ══════════════════════════════════════════════════════════════

detect_and_run "$@"
