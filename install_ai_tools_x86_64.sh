#!/bin/bash
#
# macOS AI 工具套装一键安装脚本 v1.1 (Intel x86_64 专用)
# 作者: Claude Code for Professor Xueheng Li
# 日期: 2026-01-30
#
# 用法: ./install_ai_tools_x86_64.sh [选项]
#   --skip-vscode     跳过 VSCode 安装
#   --skip-python     跳过 Python 相关安装
#   --with-skills     安装 Skills (默认跳过)
#   --skip-plugins    跳过 VSCode 插件安装
#   --dry-run         只显示将要执行的操作，不实际执行
#   --help            显示帮助信息

set -e

# ══════════════════════════════════════════════════════════════
# 架构检查 - 仅限 Intel Mac
# ══════════════════════════════════════════════════════════════

ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
    echo "错误: 此脚本仅适用于 Intel Mac (x86_64)"
    echo "当前架构: $ARCH"
    echo ""
    if [[ "$ARCH" == "arm64" ]]; then
        echo "请使用 install_ai_tools_arm64.sh 或通用版 install_ai_tools.sh"
    fi
    exit 1
fi

# 硬编码 Intel Mac 的 Homebrew 路径
BREW_PREFIX="/usr/local"
ARCH_NAME="Intel (x86_64)"

# 获取脚本所在目录 (用于定位 recommended_skills 等相对路径)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ══════════════════════════════════════════════════════════════
# 颜色和日志函数
# ══════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

LOG_FILE="$HOME/ai_tools_install.log"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}     macOS AI 工具套装一键安装脚本 v1.1 (Intel x86_64)        ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_footer() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}                       安装完成！                             ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}[$1/$TOTAL_STEPS] $2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

info() {
    echo -e "${BLUE}[检测]${NC} $1"
    log "INFO: $1"
}

skip() {
    echo -e "${YELLOW}[跳过]${NC} $1 ${GREEN}✓${NC}"
    log "SKIP: $1"
}

installing() {
    echo -e "${CYAN}[安装中]${NC} $1"
    log "INSTALLING: $1"
}

success() {
    echo -e "${GREEN}[成功]${NC} $1 ${GREEN}✓${NC}"
    log "SUCCESS: $1"
}

error() {
    echo -e "${RED}[错误]${NC} $1 ${RED}✗${NC}"
    log "ERROR: $1"
}

warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
    log "WARNING: $1"
}

# ══════════════════════════════════════════════════════════════
# 命令行参数解析
# ══════════════════════════════════════════════════════════════

SKIP_VSCODE=false
SKIP_PYTHON=false
SKIP_SKILLS=true    # 默认跳过 Skills 和 SYSU Awesome CC
SKIP_PLUGINS=false
DRY_RUN=false

show_help() {
    echo "macOS AI 工具套装一键安装脚本 v1.1 (Intel x86_64 专用)"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --skip-vscode     跳过 VSCode 安装"
    echo "  --skip-python     跳过 Python 相关安装"
    echo "  --with-skills     安装 Skills 和 SYSU Awesome CC (默认跳过)"
    echo "  --skip-plugins    跳过 VSCode 插件安装"
    echo "  --dry-run         只显示将要执行的操作，不实际执行"
    echo "  --help            显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                      # 基础安装 (不含 Skills)"
    echo "  $0 --with-skills        # 完整安装 (含 Skills)"
    echo "  $0 --skip-vscode        # 跳过 VSCode"
    echo "  $0 --dry-run            # 预览模式"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-vscode)
            SKIP_VSCODE=true
            shift
            ;;
        --skip-python)
            SKIP_PYTHON=true
            shift
            ;;
        --with-skills)
            SKIP_SKILLS=false
            shift
            ;;
        --skip-plugins)
            SKIP_PLUGINS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo "未知选项: $1"
            echo "使用 --help 查看帮助"
            exit 1
            ;;
    esac
done

# ══════════════════════════════════════════════════════════════
# 工具检测函数
# ══════════════════════════════════════════════════════════════

is_installed() {
    command -v "$1" &> /dev/null
}

is_brew_installed() {
    brew list "$1" &> /dev/null 2>&1
}

is_cask_installed() {
    brew list --cask "$1" &> /dev/null 2>&1
}

is_xcode_cli_installed() {
    xcode-select -p &> /dev/null
}

# Check if CLT needs update by checking softwareupdate for available updates
is_xcode_cli_outdated() {
    if ! xcode-select -p &> /dev/null; then
        return 1  # Not installed, so not "outdated"
    fi

    # Check softwareupdate for CLT updates available
    if softwareupdate --list 2>&1 | grep -qi "Command Line Tools"; then
        return 0  # Update available means current is outdated
    fi

    return 1  # Not outdated
}

is_vscode_extension_installed() {
    code --list-extensions 2>/dev/null | grep -q "^$1$"
}

# 检测 macOS 应用是否安装 (直接检测 .app 文件)
is_app_installed() {
    [[ -d "/Applications/$1.app" ]]
}

# ══════════════════════════════════════════════════════════════
# 安装函数
# ══════════════════════════════════════════════════════════════

ensure_zsh_default() {
    # 确保 zsh 是默认 shell (macOS Catalina+ 默认，但旧账户可能是 bash)
    local current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "zsh" ]]; then
        info "默认 shell 已是 zsh"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将设置 zsh 为默认 shell"
        return 0
    fi

    echo ""
    echo -e "${YELLOW}当前默认 shell 是 $current_shell，建议使用 zsh${NC}"
    read -p "是否将默认 shell 设置为 zsh? [Y/n]: " set_zsh

    if [[ ! "$set_zsh" =~ ^[Nn]$ ]]; then
        installing "正在设置 zsh 为默认 shell..."
        chsh -s /bin/zsh
        success "已设置 zsh 为默认 shell (重新登录后生效)"
        export SHELL=/bin/zsh
    else
        warning "跳过 zsh 设置，部分配置可能需要手动添加到您的 shell 配置文件"
    fi
}

install_xcode_cli() {
    print_section 1 "Xcode Command Line Tools"

    if is_xcode_cli_installed; then
        # Check if outdated
        if is_xcode_cli_outdated; then
            warning "Xcode CLT 已安装但版本过旧，需要更新"

            if $DRY_RUN; then
                info "[DRY-RUN] 将重新安装 Xcode Command Line Tools"
                return 0
            fi

            echo ""
            echo -e "${YELLOW}检测到 Xcode Command Line Tools 版本过旧${NC}"
            echo -e "将执行以下操作："
            echo -e "  1. 删除旧版本"
            echo -e "  2. 重新安装最新版本"
            echo ""
            read -p "按回车键继续，或 Ctrl+C 取消..." -r

            # Remove old CLT
            installing "正在删除旧版本..."
            sudo rm -rf /Library/Developer/CommandLineTools

            # Reinstall
            installing "正在重新安装 Xcode Command Line Tools..."
            xcode-select --install 2>/dev/null || true

            echo "请在弹出的窗口中点击「安装」，等待安装完成后按回车继续..."
            read -r
        else
            skip "已安装"
            return 0
        fi
    else
        # Fresh install
        if $DRY_RUN; then
            info "[DRY-RUN] 将安装 Xcode Command Line Tools"
            return 0
        fi

        installing "正在安装 Xcode Command Line Tools..."
        xcode-select --install 2>/dev/null || true

        # 等待安装完成
        echo "请在弹出的窗口中点击「安装」，等待安装完成后按回车继续..."
        read -r
    fi

    if is_xcode_cli_installed; then
        success "Xcode Command Line Tools 安装完成"
    else
        error "Xcode Command Line Tools 安装失败，请手动安装后重试"
        return 1
    fi
}

install_homebrew() {
    print_section 2 "Homebrew"

    if is_installed brew; then
        # 检查并配置清华镜像源（即使已安装也需要配置）
        if ! grep -q 'HOMEBREW_API_DOMAIN' ~/.zprofile 2>/dev/null; then
            echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"' >> ~/.zprofile
            echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.zprofile
            echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> ~/.zprofile
            echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> ~/.zprofile
            export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
            export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
            export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
            export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
            skip "已安装 ($(brew --version | head -n1))，已补充配置清华源"
        else
            skip "已安装 ($(brew --version | head -n1))"
        fi
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Homebrew"
        return 0
    fi

    installing "正在安装 Homebrew (使用清华镜像源)..."
    # 安装前先设置镜像源环境变量
    export HOMEBREW_INSTALL_FROM_API=1
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

    # 从清华镜像克隆安装脚本
    rm -rf /tmp/brew-install
    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git /tmp/brew-install
    /bin/bash /tmp/brew-install/install.sh
    rm -rf /tmp/brew-install

    # Intel Mac: /usr/local/bin 通常已在 PATH 中，无需额外配置

    # 配置清华镜像源 (写入 ~/.zprofile 永久生效)
    if ! grep -q 'HOMEBREW_API_DOMAIN' ~/.zprofile 2>/dev/null; then
        echo 'export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"' >> ~/.zprofile
        echo 'export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"' >> ~/.zprofile
        echo 'export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"' >> ~/.zprofile
        echo 'export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"' >> ~/.zprofile
        info "已配置 Homebrew 清华镜像源"
    fi
    # 立即生效
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

    if is_installed brew; then
        success "Homebrew 安装完成 (已配置清华源)"
    else
        error "Homebrew 安装失败"
        return 1
    fi
}

install_git() {
    print_section 3 "Git"

    if is_installed git; then
        skip "已安装 ($(git --version))"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Git"
        return 0
    fi

    installing "正在安装 Git..."
    brew install git

    # 配置 Git
    if [[ -z "$(git config --global user.name)" ]]; then
        echo ""
        read -p "请输入 Git 用户名: " GIT_NAME
        read -p "请输入 Git 邮箱: " GIT_EMAIL
        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"
        success "Git 配置完成"
    fi

    success "Git 安装完成"
}

install_nodejs() {
    print_section 4 "Node.js"

    if is_installed node; then
        skip "已安装 ($(node --version))"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Node.js"
        return 0
    fi

    installing "正在安装 Node.js..."
    brew install node

    if is_installed node; then
        success "Node.js 安装完成 ($(node --version))"
    else
        error "Node.js 安装失败"
        return 1
    fi
}

install_python() {
    print_section 5 "Python3"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    # Python 由 Miniconda 统一管理，不再单独安装 Homebrew Python
    info "Python 由 Miniconda 管理 (见步骤 6)"
    skip "将在 Miniconda 步骤安装"
}

install_miniconda() {
    print_section 6 "Miniconda"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    # 检查是否已安装
    if is_cask_installed miniconda || [[ -d "$HOME/miniconda3" ]] || [[ -d "/opt/miniconda3" ]] || is_installed conda; then
        skip "已安装"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Miniconda"
        info "[DRY-RUN] 将初始化 conda 并在 base 环境安装数据科学包"
        return 0
    fi

    installing "正在安装 Miniconda..."
    brew install --cask miniconda

    # 获取 miniconda 安装路径 (Intel Mac 使用 /usr/local)
    local CONDA_PATH=""
    if [[ -d "$BREW_PREFIX/Caskroom/miniconda/base" ]]; then
        CONDA_PATH="$BREW_PREFIX/Caskroom/miniconda/base"
    elif [[ -d "$HOME/miniconda3" ]]; then
        CONDA_PATH="$HOME/miniconda3"
    fi

    if [[ -z "$CONDA_PATH" ]]; then
        warning "无法确定 Miniconda 安装路径，跳过初始化"
        return 0
    fi

    # 初始化 conda for zsh
    installing "正在初始化 conda..."
    "$CONDA_PATH/bin/conda" init zsh

    # 禁用 base 环境自动激活
    "$CONDA_PATH/bin/conda" config --set auto_activate_base false

    # 在 base 环境安装数据科学包
    installing "正在安装数据科学包到 base 环境..."
    "$CONDA_PATH/bin/conda" install -n base python=3.11 pandas numpy matplotlib scipy openpyxl xlrd jupyter -y || warning "部分 conda 包安装失败"

    # markitdown 不在 conda 官方源，使用 pip 安装
    "$CONDA_PATH/bin/pip" install markitdown || warning "markitdown 安装失败"

    success "Miniconda 安装完成"
    info "请执行 'source ~/.zshrc' 或重启终端以使 conda 生效"
}

install_vscode() {
    print_section 7 "Visual Studio Code"

    if $SKIP_VSCODE; then
        skip "用户选择跳过"
        return 0
    fi

    # 检测: Homebrew cask / code 命令 / .app 文件
    if is_cask_installed visual-studio-code || is_installed code || is_app_installed "Visual Studio Code"; then
        skip "已安装"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Visual Studio Code"
        return 0
    fi

    installing "正在安装 Visual Studio Code..."
    brew install --cask visual-studio-code

    if is_installed code || is_app_installed "Visual Studio Code"; then
        success "Visual Studio Code 安装完成"
    else
        error "Visual Studio Code 安装失败"
        return 1
    fi
}

install_opencode() {
    print_section 8 "OpenCode"

    if is_installed opencode; then
        skip "已安装 ($(opencode --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 OpenCode"
        return 0
    fi

    installing "正在安装 OpenCode..."
    # 使用正确的 tap: anomalyco/tap (而非过时的 opencode-ai/tap)
    brew install anomalyco/tap/opencode

    if is_installed opencode; then
        success "OpenCode 安装完成"
    else
        error "OpenCode 安装失败"
        return 1
    fi
}

install_claude_code() {
    print_section 9 "Claude Code"

    if is_installed claude; then
        skip "已安装 ($(claude --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Claude Code"
        return 0
    fi

    installing "正在安装 Claude Code..."
    brew install --cask claude-code

    if is_installed claude; then
        success "Claude Code 安装完成"
    else
        error "Claude Code 安装失败"
        return 1
    fi
}

install_recommended_skills() {
    print_section 10 "推荐 Skills"

    # 使用脚本所在目录的相对路径
    local SKILLS_SRC="$SCRIPT_DIR/recommended_skills"
    local SKILLS_DEST="$HOME/.claude/skills"

    # 检查源目录是否存在
    if [[ ! -d "$SKILLS_SRC" ]]; then
        warning "推荐 Skills 源目录不存在: $SKILLS_SRC"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将复制推荐 Skills 到 $SKILLS_DEST"
        local count=$(ls -d "$SKILLS_SRC"/*/ 2>/dev/null | wc -l | tr -d ' ')
        info "[DRY-RUN] 找到 $count 个推荐 Skills"
        return 0
    fi

    # 创建目标目录
    mkdir -p "$SKILLS_DEST"

    # 复制 skills
    installing "正在复制推荐 Skills 到 $SKILLS_DEST..."
    cp -R "$SKILLS_SRC"/* "$SKILLS_DEST"/ 2>/dev/null || true

    local count=$(ls -d "$SKILLS_DEST"/*/ 2>/dev/null | wc -l | tr -d ' ')
    success "已安装 $count 个推荐 Skills"
}

install_cc_switch() {
    print_section 11 "CC-Switch"

    # 检测: Homebrew cask / .app 文件
    if is_cask_installed cc-switch || is_app_installed "CC-Switch"; then
        skip "已安装"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 CC-Switch"
        return 0
    fi

    installing "正在安装 CC-Switch..."
    brew tap farion1231/ccswitch
    brew install --cask cc-switch

    if is_cask_installed cc-switch || is_app_installed "CC-Switch"; then
        success "CC-Switch 安装完成"
    else
        warning "CC-Switch 安装失败，可能需要手动安装"
        return 0
    fi
}

install_uv() {
    print_section 12 "uv (Python 包管理器)"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    if is_installed uv; then
        skip "已安装 ($(uv --version))"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 uv"
        return 0
    fi

    installing "正在安装 uv..."
    brew install uv

    if is_installed uv; then
        success "uv 安装完成 ($(uv --version))"
    else
        error "uv 安装失败"
        return 1
    fi
}

install_data_tools() {
    print_section 13 "数据处理工具 (pandoc, wget, jq, tree, ffmpeg)"

    local tools=("pandoc" "wget" "jq" "tree" "ffmpeg")
    local installed=()
    local to_install=()

    for tool in "${tools[@]}"; do
        if is_brew_installed "$tool" || is_installed "$tool"; then
            installed+=("$tool")
        else
            to_install+=("$tool")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        skip "全部已安装 (${installed[*]})"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装: ${to_install[*]}"
        return 0
    fi

    for tool in "${to_install[@]}"; do
        installing "正在安装 $tool..."
        brew install "$tool" || warning "$tool 安装失败"
    done

    success "数据处理工具安装完成"
}

install_python_libs() {
    print_section 14 "Python 库"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    # 主要数据科学包已在 Miniconda 步骤 6 安装
    # 此步骤仅作为备用检查和提示

    if $DRY_RUN; then
        info "[DRY-RUN] 检查 Python 库安装状态"
        info "[DRY-RUN] 主要包 (pandas, numpy, jupyter 等) 已在 Miniconda base 环境安装"
        return 0
    fi

    info "主要数据科学包已在 Miniconda base 环境中安装 (步骤 6)"
    info "已安装: python=3.11, pandas, numpy, matplotlib, scipy, openpyxl, xlrd, jupyter, markitdown"
    skip "主要包已在 Miniconda 步骤安装"
}

install_vscode_extensions() {
    print_section 15 "VSCode 插件"

    if $SKIP_VSCODE || $SKIP_PLUGINS; then
        skip "用户选择跳过"
        return 0
    fi

    if ! is_installed code; then
        skip "VSCode 未安装，跳过插件安装"
        return 0
    fi

    local extensions=(
        "shd101wyy.markdown-preview-enhanced"
        "yzhang.markdown-all-in-one"
        "yzane.markdown-pdf"
        "cweijan.vscode-office"
        "ms-toolsai.datawrangler"
        "mhutchie.git-graph"
        "James-Yu.latex-workshop"
        "marp-team.marp-vscode"
    )

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 VSCode 插件:"
        for ext in "${extensions[@]}"; do
            echo "  - $ext"
        done
        return 0
    fi

    for ext in "${extensions[@]}"; do
        if is_vscode_extension_installed "$ext"; then
            skip "$ext 已安装"
        else
            installing "安装 $ext..."
            code --install-extension "$ext" || warning "$ext 安装失败"
        fi
    done

    success "VSCode 插件安装完成"
}

install_skills() {
    print_section 16 "Anthropic Skills (手动安装提示)"

    if $SKIP_SKILLS; then
        skip "用户选择跳过"
        return 0
    fi

    if ! is_installed claude; then
        skip "Claude Code 未安装，跳过 Skills 安装"
        return 0
    fi

    local plugin_dir="$HOME/.claude/plugins/document-skills"
    if [[ -d "$plugin_dir" ]]; then
        skip "Document Skills 已安装"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将显示 Anthropic Skills 安装说明"
        return 0
    fi

    # Skills 需要在 Claude Code 交互模式下安装
    echo ""
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│  Anthropic Skills 需要在 Claude Code 中手动安装                │${NC}"
    echo -e "${YELLOW}├────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${YELLOW}│  启动 Claude Code 后，运行以下命令:                            │${NC}"
    echo -e "${YELLOW}│                                                                │${NC}"
    echo -e "${YELLOW}│  1. 添加 Marketplace:                                          │${NC}"
    echo -e "${YELLOW}│     ${CYAN}/plugin marketplace add anthropics/skills${YELLOW}                │${NC}"
    echo -e "${YELLOW}│                                                                │${NC}"
    echo -e "${YELLOW}│  2. 安装 Document Skills:                                      │${NC}"
    echo -e "${YELLOW}│     ${CYAN}/plugin install document-skills@anthropic-agent-skills${YELLOW}   │${NC}"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────┘${NC}"
    echo ""

    warning "Skills 需要手动安装 (见上方说明)"
}

install_document_skills() {
    # 合并到 install_skills 函数中，此函数保留但不执行任何操作
    return 0
}

install_sysu_awesome_cc() {
    print_section 18 "SYSU Awesome CC"

    if $SKIP_SKILLS; then
        skip "用户选择跳过"
        return 0
    fi

    # 检查是否已安装（检查任意一个目标目录是否有来自该仓库的文件）
    local marker_file="$HOME/.claude/.sysu-awesome-cc-installed"
    if [[ -f "$marker_file" ]]; then
        skip "已安装"
        return 0
    fi

    if ! is_installed git; then
        skip "Git 未安装，跳过 SYSU Awesome CC 安装"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 SYSU Awesome CC:"
        echo "  - agents/  → ~/.claude/agents/"
        echo "  - skills/  → ~/.claude/skills/"
        echo "  - commands/ → ~/.claude/commands/"
        return 0
    fi

    installing "正在安装 SYSU Awesome CC..."

    # 创建临时目录
    local temp_dir=$(mktemp -d)

    # 克隆仓库到临时目录
    git clone --depth 1 https://github.com/Xueheng-Li/sysu-awesome-cc.git "$temp_dir/sysu-awesome-cc"

    if [[ ! -d "$temp_dir/sysu-awesome-cc" ]]; then
        error "克隆仓库失败"
        rm -rf "$temp_dir"
        return 1
    fi

    # 确保目标目录存在
    mkdir -p "$HOME/.claude/agents"
    mkdir -p "$HOME/.claude/skills"
    mkdir -p "$HOME/.claude/commands"

    # 复制 agents
    if [[ -d "$temp_dir/sysu-awesome-cc/agents" ]]; then
        cp -r "$temp_dir/sysu-awesome-cc/agents/"* "$HOME/.claude/agents/" 2>/dev/null || true
        info "已安装 agents/"
    fi

    # 复制 skills
    if [[ -d "$temp_dir/sysu-awesome-cc/skills" ]]; then
        cp -r "$temp_dir/sysu-awesome-cc/skills/"* "$HOME/.claude/skills/" 2>/dev/null || true
        info "已安装 skills/"
    fi

    # 复制 commands
    if [[ -d "$temp_dir/sysu-awesome-cc/commands" ]]; then
        cp -r "$temp_dir/sysu-awesome-cc/commands/"* "$HOME/.claude/commands/" 2>/dev/null || true
        info "已安装 commands/"
    fi

    # 创建安装标记文件
    echo "Installed from https://github.com/Xueheng-Li/sysu-awesome-cc" > "$marker_file"
    echo "Date: $(date)" >> "$marker_file"

    # 清理临时目录
    rm -rf "$temp_dir"

    success "SYSU Awesome CC 安装完成"
}

install_clash_verge() {
    print_section 19 "Clash Verge Rev (网络代理)"

    local already_installed=false

    # 检测: Homebrew cask / .app 文件
    if is_cask_installed clash-verge-rev || is_app_installed "Clash Verge"; then
        skip "已安装"
        already_installed=true
    elif $DRY_RUN; then
        info "[DRY-RUN] 将安装 Clash Verge Rev"
        info "[DRY-RUN] 安装完成后将询问是否配置代理环境变量"
        return 0
    else
        installing "正在安装 Clash Verge Rev..."
        brew install --cask clash-verge-rev

        if is_cask_installed clash-verge-rev || is_app_installed "Clash Verge"; then
            success "Clash Verge Rev 安装完成"
        else
            warning "Clash Verge Rev 安装失败，可能需要手动安装"
            return 0
        fi
    fi

    # 询问是否配置代理环境变量（无论是新安装还是已安装）
    configure_proxy_env
}

configure_proxy_env() {
    local proxy_config='export http_proxy=http://127.0.0.1:7890 && export https_proxy=http://127.0.0.1:7890'

    echo ""
    echo -e "${YELLOW}是否将代理配置添加到 ~/.zshrc？${NC}"
    echo -e "  ${CYAN}$proxy_config${NC}"
    echo ""
    read -p "添加到 ~/.zshrc? [y/N]: " add_proxy

    if [[ "$add_proxy" =~ ^[Yy]$ ]]; then
        local proxy_lines="
# Clash Verge Rev proxy configuration
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890"

        # 只添加到 ~/.zshrc (macOS 默认 shell)
        if [[ -f "$HOME/.zshrc" ]]; then
            if ! grep -q "http_proxy=http://127.0.0.1:7890" "$HOME/.zshrc"; then
                echo "$proxy_lines" >> "$HOME/.zshrc"
                info "已添加到 ~/.zshrc"
            else
                skip "~/.zshrc 已包含代理配置"
            fi
        else
            # 确保 .zshrc 存在
            echo "$proxy_lines" >> "$HOME/.zshrc"
            info "已创建 ~/.zshrc 并添加代理配置"
        fi

        success "代理配置已添加，重启终端或运行 'source ~/.zshrc' 生效"
    else
        info "跳过代理配置"
    fi
}

# ══════════════════════════════════════════════════════════════
# 最终验证
# ══════════════════════════════════════════════════════════════

verify_installation() {
    echo ""
    echo -e "${BOLD}已安装工具:${NC}"

    local tools=(
        "brew:Homebrew"
        "git:Git"
        "node:Node.js"
        "python3:Python3"
        "conda:Miniconda"
        "code:VSCode"
        "opencode:OpenCode"
        "claude:Claude Code"
        "uv:uv"
        "pandoc:Pandoc"
        "wget:wget"
        "jq:jq"
        "tree:tree"
        "ffmpeg:FFmpeg"
    )

    for item in "${tools[@]}"; do
        local cmd="${item%%:*}"
        local name="${item##*:}"
        if is_installed "$cmd"; then
            local version=$($cmd --version 2>/dev/null | head -n1 || echo "installed")
            echo -e "  ${GREEN}✓${NC} $name: $version"
        else
            echo -e "  ${RED}✗${NC} $name: 未安装"
        fi
    done

    # 检查 Cask 应用
    if is_cask_installed cc-switch || is_app_installed "CC-Switch"; then
        echo -e "  ${GREEN}✓${NC} CC-Switch: installed"
    else
        echo -e "  ${RED}✗${NC} CC-Switch: 未安装"
    fi

    if is_cask_installed clash-verge-rev || is_app_installed "Clash Verge"; then
        echo -e "  ${GREEN}✓${NC} Clash Verge Rev: installed"
    else
        echo -e "  ${RED}✗${NC} Clash Verge Rev: 未安装"
    fi

    # 检查 Claude Code 插件 (仅在未跳过时显示)
    if ! $SKIP_SKILLS; then
        echo ""
        echo -e "${BOLD}已安装插件:${NC}"

        # Document Skills
        if [[ -d "$HOME/.claude/plugins/document-skills" ]]; then
            echo -e "  ${GREEN}✓${NC} Document Skills"
        else
            echo -e "  ${RED}✗${NC} Document Skills: 未安装"
        fi

        # SYSU Awesome CC
        if [[ -f "$HOME/.claude/.sysu-awesome-cc-installed" ]]; then
            echo -e "  ${GREEN}✓${NC} SYSU Awesome CC"
            # 显示详情
            [[ -d "$HOME/.claude/agents" ]] && echo -e "      └─ agents/"
            [[ -d "$HOME/.claude/skills" ]] && echo -e "      └─ skills/"
            [[ -d "$HOME/.claude/commands" ]] && echo -e "      └─ commands/"
        else
            echo -e "  ${RED}✗${NC} SYSU Awesome CC: 未安装"
        fi
    fi
}

print_next_steps() {
    echo ""
    echo -e "${BOLD}下一步:${NC}"
    echo "  1. 运行 'source ~/.zshrc' 使 conda 配置生效"
    echo "  2. 打开 CC-Switch 应用配置 API 密钥"
    echo "  3. 或运行 'claude login' 登录 Anthropic 账号"
    echo "  4. 运行 'opencode' 或 'claude' 开始使用"
    echo ""
    echo -e "安装日志已保存到: ${CYAN}$LOG_FILE${NC}"
}

# ══════════════════════════════════════════════════════════════
# 主流程
# ══════════════════════════════════════════════════════════════

TOTAL_STEPS=19

main() {
    # 初始化日志
    echo "========================================" >> "$LOG_FILE"
    log "安装开始 (Intel x86_64 专用脚本)"

    # 显示头部
    print_header

    if $DRY_RUN; then
        echo -e "${YELLOW}[预览模式] 以下操作不会实际执行${NC}"
        echo ""
    fi

    info "系统架构: $ARCH_NAME"
    info "Homebrew 路径: $BREW_PREFIX"

    # 确保 zsh 是默认 shell
    ensure_zsh_default

    # 执行安装 (共 18 步)
    install_xcode_cli        # 1
    install_homebrew         # 2
    install_git              # 3
    install_nodejs           # 4
    install_python           # 5
    install_miniconda        # 6 (新增)
    install_vscode           # 7
    install_opencode           # 8
    install_claude_code        # 9
    install_recommended_skills # 10
    install_cc_switch          # 11
    install_uv                 # 12
    install_data_tools         # 13
    install_python_libs        # 14
    install_vscode_extensions  # 15
    install_skills             # 16
    install_document_skills    # 17 (空操作，保留兼容性)
    install_sysu_awesome_cc    # 18
    install_clash_verge        # 19

    # 显示结果
    print_footer
    verify_installation
    print_next_steps

    log "安装完成"
}

# 运行主流程
main
