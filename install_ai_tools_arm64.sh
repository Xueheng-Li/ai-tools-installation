#!/bin/bash
#
# macOS AI 工具套装一键安装脚本 v1.1 (Apple Silicon 专用版)
# 作者: Claude Code for Professor Xueheng Li
# 日期: 2026-01-30
#
# 用法: ./install_ai_tools_arm64.sh [选项]
#   --skip-vscode     跳过 VSCode 安装
#   --skip-python     跳过 Python 相关安装
#   --with-skills     安装 Skills (默认跳过)
#   --skip-plugins    跳过 VSCode 插件安装
#   --dry-run         只显示将要执行的操作，不实际执行
#   --help            显示帮助信息

set -e

# ══════════════════════════════════════════════════════════════
# 架构检查 (Apple Silicon 专用)
# ══════════════════════════════════════════════════════════════

ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
    echo ""
    echo "错误: 此脚本仅适用于 Apple Silicon (arm64) Mac"
    echo "当前系统架构: $ARCH"
    echo ""
    echo "请使用以下脚本:"
    echo "  - Intel Mac: install_ai_tools_x86_64.sh (如可用)"
    echo "  - 通用版本: install_ai_tools.sh"
    echo ""
    exit 1
fi

# 检测是否在 Rosetta 2 下运行
if [[ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" == "1" ]]; then
    echo ""
    echo "警告: 检测到在 Rosetta 2 下运行 (x86_64 模拟模式)"
    echo "建议使用原生 ARM 终端以获得最佳性能和兼容性"
    echo ""
    read -p "是否继续? [y/N]: " continue_rosetta
    if [[ ! "$continue_rosetta" =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# ══════════════════════════════════════════════════════════════
# 硬编码架构配置 (Apple Silicon)
# ══════════════════════════════════════════════════════════════

BREW_PREFIX="/opt/homebrew"
ARCH_NAME="Apple Silicon (arm64)"

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
    echo -e "${CYAN}║${BOLD}      macOS AI 工具套装一键安装脚本 v1.1 (Apple Silicon)      ${NC}${CYAN}║${NC}"
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
    echo "macOS AI 工具套装一键安装脚本 v1.1 (Apple Silicon 专用)"
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

is_vscode_extension_installed() {
    code --list-extensions 2>/dev/null | grep -q "^$1$"
}

# 检测 .app 是否存在于 /Applications
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
        skip "已安装"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Xcode Command Line Tools"
        return 0
    fi

    installing "正在安装 Xcode Command Line Tools..."
    xcode-select --install 2>/dev/null || true

    # 等待安装完成
    echo "请在弹出的窗口中点击「安装」，等待安装完成后按回车继续..."
    read -r

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
        skip "已安装 ($(brew --version | head -n1))"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Homebrew"
        return 0
    fi

    installing "正在安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon 需要添加 Homebrew 到 PATH
    if ! grep -q '/opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        info "已添加 Homebrew 到 ~/.zprofile"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"

    if is_installed brew; then
        success "Homebrew 安装完成"
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

    if is_brew_installed python3 || is_brew_installed python@3.12 || is_brew_installed python@3.11; then
        skip "已安装 ($(python3 --version))"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Python3"
        return 0
    fi

    installing "正在安装 Python3..."
    brew install python3

    if is_installed python3; then
        success "Python3 安装完成 ($(python3 --version))"
    else
        error "Python3 安装失败"
        return 1
    fi
}

install_miniconda() {
    print_section 6 "Miniconda"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    # 检测 Miniconda 是否已安装
    if [[ -d "$HOME/miniconda3" ]] || [[ -d "/opt/homebrew/Caskroom/miniconda" ]] || is_cask_installed miniconda; then
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

    # 获取 Miniconda 安装路径
    local CONDA_PATH=""
    if [[ -d "/opt/homebrew/Caskroom/miniconda/base" ]]; then
        CONDA_PATH="/opt/homebrew/Caskroom/miniconda/base"
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

    # 检测 VSCode: Homebrew 安装、code 命令、或 .app 文件
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
    # 使用正确的 tap: anomalyco/tap (不是 opencode-ai/tap)
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

install_cc_switch() {
    print_section 10 "CC-Switch"

    # 检测 CC-Switch: Homebrew 安装或 .app 文件
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
    print_section 11 "uv (Python 包管理器)"

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
    print_section 12 "数据处理工具 (pandoc, wget, jq, tree, ffmpeg)"

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
    print_section 13 "Python 库 (Homebrew Python)"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    # 注意: 主要的数据科学包已在 Miniconda base 环境中安装
    # 此步骤为 Homebrew Python 安装基础包 (可选)

    local libs=("markitdown")

    if $DRY_RUN; then
        info "[DRY-RUN] 将为 Homebrew Python 安装: ${libs[*]}"
        info "[DRY-RUN] 注: 主要数据科学包已在 Miniconda base 环境中安装"
        return 0
    fi

    installing "正在为 Homebrew Python 安装基础包..."
    pip3 install --upgrade pip 2>/dev/null || true
    pip3 install "${libs[@]}" 2>/dev/null || warning "部分包安装失败"

    success "Python 库安装完成"
    info "提示: 数据科学包 (pandas, numpy 等) 已安装在 Miniconda base 环境中"
    info "使用 'conda activate base' 激活环境后使用"
}

install_vscode_extensions() {
    print_section 14 "VSCode 插件"

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
    print_section 15 "Anthropic Skills (手动安装提示)"

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
    print_section 17 "SYSU Awesome CC"

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
    print_section 18 "Clash Verge Rev (网络代理)"

    local already_installed=false

    # 检测 Clash Verge: Homebrew 安装或 .app 文件
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
    echo "  1. 执行 'source ~/.zshrc' 或重启终端使配置生效"
    echo "  2. 打开 CC-Switch 应用配置 API 密钥"
    echo "  3. 或运行 'claude login' 登录 Anthropic 账号"
    echo "  4. 运行 'opencode' 或 'claude' 开始使用"
    echo ""
    echo -e "${BOLD}Miniconda 使用提示:${NC}"
    echo "  - 激活 base 环境: conda activate base"
    echo "  - 退出环境: conda deactivate"
    echo "  - 已预装: pandas, numpy, matplotlib, scipy, jupyter 等"
    echo ""
    echo -e "安装日志已保存到: ${CYAN}$LOG_FILE${NC}"
}

# ══════════════════════════════════════════════════════════════
# 主流程
# ══════════════════════════════════════════════════════════════

TOTAL_STEPS=18

main() {
    # 初始化日志
    echo "========================================" >> "$LOG_FILE"
    log "安装开始 (Apple Silicon 专用版)"

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

    # 执行安装
    install_xcode_cli          # 1
    install_homebrew           # 2
    install_git                # 3
    install_nodejs             # 4
    install_python             # 5
    install_miniconda          # 6 (新增)
    install_vscode             # 7
    install_opencode           # 8
    install_claude_code        # 9
    install_cc_switch          # 10
    install_uv                 # 11
    install_data_tools         # 12
    install_python_libs        # 13
    install_vscode_extensions  # 14
    install_skills             # 15
    install_document_skills    # 16 (空操作)
    install_sysu_awesome_cc    # 17
    install_clash_verge        # 18

    # 显示结果
    print_footer
    verify_installation
    print_next_steps

    log "安装完成"
}

# 运行主流程
main
