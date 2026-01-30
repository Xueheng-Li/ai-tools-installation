#!/bin/bash
#
# macOS AI 工具套装离线安装脚本 v1.0
# 作者: Claude Code for Professor Xueheng Li
# 日期: 2026-01-30
#
# 用法: ./install_ai_tools_offline.sh [选项]
#   --skip-vscode     跳过 VSCode 安装
#   --skip-python     跳过 Python 相关安装
#   --with-skills     安装 Skills (默认跳过)
#   --skip-plugins    跳过 VSCode 插件安装
#   --dry-run         只显示将要执行的操作，不实际执行
#   --help            显示帮助信息
#
# 离线安装包目录结构 (此脚本位于 apps/ 目录内):
# ├── xcode-clt/              - Xcode CLT .pkg (手动下载)
# ├── casks/
# │   ├── visual-studio-code/{arm64,x86_64}/
# │   ├── claude-code/{arm64,x86_64}/
# │   ├── opencode/{arm64,x86_64}/  - opencode-mac-arm64.tar.gz / opencode-mac-x86_64.tar.gz
# │   ├── cc-switch/universal/      - CC-Switch-*.zip (仅 universal 版本)
# │   └── clash-verge-rev/{arm64,x86_64}/
# ├── vscode-extensions/*.vsix
# ├── python/                       - Python 包 (不分架构)
# └── skills/
#     ├── anthropics-skills/
#     └── sysu-awesome-cc/

set -e

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

LOG_FILE="$HOME/ai_tools_offline_install.log"

# 脚本所在目录 (离线包根目录)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR"

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}        macOS AI 工具套装离线安装脚本 v1.0                    ${NC}${CYAN}║${NC}"
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
    echo "macOS AI 工具套装离线安装脚本 v1.0"
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
    echo ""
    echo "离线包目录结构 (与此脚本同目录):"
    echo "  xcode-clt/            - Xcode CLT .pkg (手动下载)"
    echo "  casks/                - DMG 和 ZIP 应用"
    echo "  vscode-extensions/    - VSCode 插件 (.vsix)"
    echo "  python/               - Python 包 (.whl)"
    echo "  skills/               - Claude Code Skills"
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
# 系统检测
# ══════════════════════════════════════════════════════════════

detect_system() {
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        ARCH_DIR="arm64"
        ARCH_NAME="Apple Silicon (arm64)"
    else
        ARCH_DIR="x86_64"
        ARCH_NAME="Intel (x86_64)"
    fi
}

# ══════════════════════════════════════════════════════════════
# 工具检测函数
# ══════════════════════════════════════════════════════════════

is_installed() {
    command -v "$1" &> /dev/null
}

is_app_installed() {
    [[ -d "/Applications/$1.app" ]]
}

is_vscode_extension_installed() {
    code --list-extensions 2>/dev/null | grep -q "^$1$"
}

# ══════════════════════════════════════════════════════════════
# 离线包检测
# ══════════════════════════════════════════════════════════════

check_apps_dir() {
    if [[ ! -d "$APPS_DIR" ]]; then
        error "离线包目录不存在: $APPS_DIR"
        echo ""
        echo "请确保以下子目录与此脚本在同一目录下:"
        echo "  casks/                - DMG 和 ZIP 应用"
        echo "  vscode-extensions/    - VSCode 插件 (.vsix)"
        echo "  python/               - Python 包 (.whl)"
        echo "  skills/               - Claude Code Skills"
        exit 1
    fi
    success "离线包目录存在: $APPS_DIR"
}

# 查找架构对应的安装文件
find_install_file() {
    local app_name="$1"
    local cask_dir="$APPS_DIR/casks/$app_name"

    # 首先尝试架构特定目录
    local arch_dir="$cask_dir/$ARCH_DIR"
    if [[ -d "$arch_dir" ]]; then
        # 查找 DMG, ZIP, tar.gz 或二进制文件
        local file=$(ls "$arch_dir"/*.dmg 2>/dev/null | head -n1)
        [[ -n "$file" ]] && echo "$file" && return 0

        file=$(ls "$arch_dir"/*.zip 2>/dev/null | head -n1)
        [[ -n "$file" ]] && echo "$file" && return 0

        file=$(ls "$arch_dir"/*.tar.gz 2>/dev/null | head -n1)
        [[ -n "$file" ]] && echo "$file" && return 0

        # 查找二进制文件 (如 claude, opencode)
        for f in "$arch_dir"/*; do
            if [[ -f "$f" && -x "$f" ]] || [[ -f "$f" && ! "$f" =~ \. ]]; then
                echo "$f"
                return 0
            fi
        done
    fi

    # 尝试直接在 cask 目录下查找
    if [[ -d "$cask_dir" ]]; then
        local file=$(ls "$cask_dir"/*.dmg 2>/dev/null | head -n1)
        [[ -n "$file" ]] && echo "$file" && return 0

        file=$(ls "$cask_dir"/*.zip 2>/dev/null | head -n1)
        [[ -n "$file" ]] && echo "$file" && return 0
    fi

    return 1
}

# ══════════════════════════════════════════════════════════════
# DMG 安装函数
# ══════════════════════════════════════════════════════════════

install_dmg_app() {
    local dmg_path="$1"
    local app_name="$2"
    local mount_point="/tmp/dmg_mount_$$"

    installing "正在安装 $app_name (DMG)..."

    # 挂载 DMG (带错误处理)
    mkdir -p "$mount_point"
    if ! hdiutil attach "$dmg_path" -nobrowse -mountpoint "$mount_point" -quiet 2>/dev/null; then
        error "无法挂载 DMG: $dmg_path"
        rmdir "$mount_point" 2>/dev/null || true
        return 1
    fi

    # 查找 .app
    local app_path=$(find "$mount_point" -maxdepth 1 -name "*.app" -print -quit)

    if [[ -z "$app_path" ]]; then
        # 有些 DMG 包含安装程序或其他结构
        app_path=$(find "$mount_point" -maxdepth 2 -name "*.app" -print -quit)
    fi

    if [[ -n "$app_path" ]]; then
        local dest_app_name=$(basename "$app_path")
        cp -R "$app_path" "/Applications/"
        success "$dest_app_name 已安装到 /Applications/"
    else
        warning "在 DMG 中未找到 .app 文件"
    fi

    # 卸载 DMG
    hdiutil detach "$mount_point" -quiet 2>/dev/null || true
    rmdir "$mount_point" 2>/dev/null || true
}

# ══════════════════════════════════════════════════════════════
# ZIP 安装函数
# ══════════════════════════════════════════════════════════════

install_zip_app() {
    local zip_path="$1"
    local app_name="$2"

    installing "正在安装 $app_name (ZIP)..."

    # 解压到临时目录
    local temp_dir=$(mktemp -d)
    unzip -q "$zip_path" -d "$temp_dir"

    # 查找 .app
    local app_path=$(find "$temp_dir" -maxdepth 2 -name "*.app" -print -quit)

    if [[ -n "$app_path" ]]; then
        local dest_app_name=$(basename "$app_path")
        # 删除已存在的旧版本
        [[ -d "/Applications/$dest_app_name" ]] && rm -rf "/Applications/$dest_app_name"
        mv "$app_path" "/Applications/"
        success "$dest_app_name 已安装到 /Applications/"
    else
        warning "在 ZIP 中未找到 .app 文件"
    fi

    # 清理
    rm -rf "$temp_dir"
}

# ══════════════════════════════════════════════════════════════
# 二进制安装函数
# ══════════════════════════════════════════════════════════════

install_binary() {
    local binary_path="$1"
    local binary_name="$2"
    local dest_path="${3:-/usr/local/bin/$binary_name}"

    installing "正在安装 $binary_name (二进制)..."

    # 检查是否需要 sudo 权限
    local dest_dir="$(dirname "$dest_path")"
    if [[ ! -w "$dest_dir" ]]; then
        echo ""
        echo -e "${YELLOW}安装 $binary_name 需要管理员权限 (写入 $dest_path)${NC}"
        read -p "是否继续? [y/N]: " confirm_sudo
        if [[ ! "$confirm_sudo" =~ ^[Yy]$ ]]; then
            warning "用户取消安装 $binary_name"
            return 0
        fi
    fi

    # 确保目标目录存在
    sudo mkdir -p "$dest_dir"

    # 处理 tar.gz 文件
    if [[ "$binary_path" == *.tar.gz ]]; then
        local temp_dir=$(mktemp -d)
        tar -xzf "$binary_path" -C "$temp_dir"

        # 查找二进制文件
        local extracted_binary=$(find "$temp_dir" -type f -name "$binary_name" -print -quit)
        if [[ -z "$extracted_binary" ]]; then
            # 尝试查找任何可执行文件 (使用兼容新旧 macOS 的语法)
            extracted_binary=$(find "$temp_dir" -type f -perm /111 -print -quit)
        fi

        if [[ -n "$extracted_binary" ]]; then
            sudo cp "$extracted_binary" "$dest_path"
            sudo chmod +x "$dest_path"
            success "$binary_name 已安装到 $dest_path"
        else
            warning "在 tar.gz 中未找到可执行文件"
        fi

        rm -rf "$temp_dir"
    else
        # 直接复制二进制文件
        sudo cp "$binary_path" "$dest_path"
        sudo chmod +x "$dest_path"
        success "$binary_name 已安装到 $dest_path"
    fi
}

# ══════════════════════════════════════════════════════════════
# 安装函数
# ══════════════════════════════════════════════════════════════

install_xcode_clt() {
    print_section 1 "Xcode Command Line Tools"

    # 检查是否已安装
    if xcode-select -p &> /dev/null; then
        skip "已安装 ($(xcode-select -p))"
        return 0
    fi

    # 查找离线包
    local pkg_file=$(find "$APPS_DIR/xcode-clt" -name "*.pkg" 2>/dev/null | head -n1)

    if [[ -z "$pkg_file" ]]; then
        warning "未找到 Xcode CLT 离线包，尝试在线安装..."
        echo ""
        echo -e "${YELLOW}请在弹出的窗口中点击「安装」${NC}"
        xcode-select --install 2>/dev/null || true
        echo ""
        read -p "安装完成后，按回车键继续..." -r

        # 再次检查是否安装成功
        if xcode-select -p &> /dev/null; then
            success "Xcode CLT 安装完成"
        else
            warning "Xcode CLT 可能未安装成功，继续执行..."
        fi
    else
        if $DRY_RUN; then
            info "[DRY-RUN] 将安装 Xcode CLT 从: $pkg_file"
            return 0
        fi

        installing "从离线包安装: $(basename "$pkg_file")"

        echo ""
        echo -e "${YELLOW}安装 Xcode CLT 需要管理员权限${NC}"

        if sudo installer -pkg "$pkg_file" -target /; then
            if xcode-select -p &> /dev/null; then
                success "Xcode CLT 安装完成"
            else
                warning "安装命令执行成功，但 xcode-select 检测失败"
            fi
        else
            error "Xcode CLT 安装失败"
            return 1
        fi
    fi
}

install_homebrew_notice() {
    print_section 2 "Homebrew 和 Formulae (需网络)"

    echo ""
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│  以下工具需要网络安装 (Homebrew Formulae):                     │${NC}"
    echo -e "${YELLOW}├────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${YELLOW}│  - Homebrew (包管理器)                                         │${NC}"
    echo -e "${YELLOW}│  - Git, Node.js, Python3, uv                                   │${NC}"
    echo -e "${YELLOW}│  - pandoc, wget, jq, tree, ffmpeg                              │${NC}"
    echo -e "${YELLOW}├────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${YELLOW}│  如需安装，请联网后运行:                                       │${NC}"
    echo -e "${YELLOW}│  ${CYAN}../install_ai_tools.sh${YELLOW}                                        │${NC}"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────┘${NC}"
    echo ""

    warning "Homebrew 和 Formulae 需要网络安装，本脚本跳过"
}

install_vscode() {
    print_section 3 "Visual Studio Code"

    if $SKIP_VSCODE; then
        skip "用户选择跳过"
        return 0
    fi

    if is_app_installed "Visual Studio Code" || is_installed code; then
        skip "已安装"
        return 0
    fi

    local install_file=$(find_install_file "visual-studio-code")

    if [[ -z "$install_file" ]]; then
        warning "未找到 Visual Studio Code 离线安装包"
        info "应放置于: $APPS_DIR/casks/visual-studio-code/$ARCH_DIR/"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Visual Studio Code 从: $install_file"
        return 0
    fi

    if [[ "$install_file" == *.zip ]]; then
        install_zip_app "$install_file" "Visual Studio Code"
    elif [[ "$install_file" == *.dmg ]]; then
        install_dmg_app "$install_file" "Visual Studio Code"
    fi
}

install_claude_code() {
    print_section 4 "Claude Code"

    if is_installed claude; then
        skip "已安装 ($(claude --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    local install_file=$(find_install_file "claude-code")

    if [[ -z "$install_file" ]]; then
        warning "未找到 Claude Code 离线安装包"
        info "应放置于: $APPS_DIR/casks/claude-code/$ARCH_DIR/"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Claude Code 从: $install_file"
        return 0
    fi

    install_binary "$install_file" "claude" "/usr/local/bin/claude"
}

install_opencode() {
    print_section 5 "OpenCode"

    if is_installed opencode; then
        skip "已安装 ($(opencode --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    # OpenCode 文件名: opencode-mac-arm64.tar.gz 或 opencode-mac-x86_64.tar.gz
    local opencode_dir="$APPS_DIR/casks/opencode/$ARCH_DIR"
    local install_file=""

    if [[ -d "$opencode_dir" ]]; then
        if [[ "$ARCH_DIR" == "arm64" ]]; then
            install_file=$(ls "$opencode_dir"/opencode-mac-arm64.tar.gz 2>/dev/null | head -n1)
        else
            install_file=$(ls "$opencode_dir"/opencode-mac-x86_64.tar.gz 2>/dev/null | head -n1)
        fi
    fi

    # 如果没找到，尝试通用查找
    if [[ -z "$install_file" ]]; then
        install_file=$(find_install_file "opencode")
    fi

    if [[ -z "$install_file" ]]; then
        warning "未找到 OpenCode 离线安装包"
        info "应放置于: $APPS_DIR/casks/opencode/$ARCH_DIR/opencode-mac-$ARCH_DIR.tar.gz"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 OpenCode 从: $install_file"
        return 0
    fi

    install_binary "$install_file" "opencode" "/usr/local/bin/opencode"
}

install_cc_switch() {
    print_section 6 "CC-Switch"

    if is_app_installed "CC-Switch"; then
        skip "已安装"
        return 0
    fi

    # CC-Switch 只有 universal 版本，在 universal/ 目录下
    local universal_dir="$APPS_DIR/casks/cc-switch/universal"
    local install_file=""

    if [[ -d "$universal_dir" ]]; then
        install_file=$(ls "$universal_dir"/CC-Switch-*.zip 2>/dev/null | head -n1)
    fi

    if [[ -z "$install_file" ]]; then
        warning "未找到 CC-Switch 离线安装包"
        info "应放置于: $APPS_DIR/casks/cc-switch/universal/CC-Switch-*.zip"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 CC-Switch 从: $install_file"
        return 0
    fi

    install_zip_app "$install_file" "CC-Switch"
}

install_clash_verge() {
    print_section 7 "Clash Verge Rev"

    if is_app_installed "Clash Verge"; then
        skip "已安装"
        configure_proxy_env
        return 0
    fi

    local install_file=$(find_install_file "clash-verge-rev")

    if [[ -z "$install_file" ]]; then
        warning "未找到 Clash Verge Rev 离线安装包"
        info "应放置于: $APPS_DIR/casks/clash-verge-rev/$ARCH_DIR/"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装 Clash Verge Rev 从: $install_file"
        return 0
    fi

    if [[ "$install_file" == *.dmg ]]; then
        install_dmg_app "$install_file" "Clash Verge Rev"
    fi

    configure_proxy_env
}

configure_proxy_env() {
    local proxy_config='export http_proxy=http://127.0.0.1:7890 && export https_proxy=http://127.0.0.1:7890'

    echo ""
    echo -e "${YELLOW}是否将代理配置添加到 shell 配置文件？${NC}"
    echo -e "  ${CYAN}$proxy_config${NC}"
    echo ""
    read -p "添加到 shell 配置文件? [y/N]: " add_proxy

    if [[ "$add_proxy" =~ ^[Yy]$ ]]; then
        local proxy_lines="
# Clash Verge Rev proxy configuration
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890"

        # 添加到 .zshrc (macOS 默认 shell)
        if [[ -f "$HOME/.zshrc" ]]; then
            if ! grep -q "http_proxy=http://127.0.0.1:7890" "$HOME/.zshrc"; then
                echo "$proxy_lines" >> "$HOME/.zshrc"
                info "已添加到 ~/.zshrc"
            else
                skip "~/.zshrc 已包含代理配置"
            fi
        else
            echo "$proxy_lines" >> "$HOME/.zshrc"
            info "已创建 ~/.zshrc 并添加代理配置"
        fi

        # 添加到 .bash_profile (如果存在)
        if [[ -f "$HOME/.bash_profile" ]]; then
            if ! grep -q "http_proxy=http://127.0.0.1:7890" "$HOME/.bash_profile"; then
                echo "$proxy_lines" >> "$HOME/.bash_profile"
                info "已添加到 ~/.bash_profile"
            fi
        fi

        success "代理配置已添加，重启终端或运行 'source ~/.zshrc' 生效"
    else
        info "跳过代理配置"
    fi
}

install_vscode_extensions() {
    print_section 8 "VSCode 插件"

    if $SKIP_VSCODE || $SKIP_PLUGINS; then
        skip "用户选择跳过"
        return 0
    fi

    if ! is_installed code; then
        skip "VSCode 未安装，跳过插件安装"
        return 0
    fi

    local ext_dir="$APPS_DIR/vscode-extensions"

    if [[ ! -d "$ext_dir" ]]; then
        warning "VSCode 插件目录不存在: $ext_dir"
        return 0
    fi

    local vsix_files=("$ext_dir"/*.vsix)

    if [[ ! -f "${vsix_files[0]}" ]]; then
        warning "未找到 .vsix 插件文件"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将安装以下 VSCode 插件:"
        for vsix in "${vsix_files[@]}"; do
            echo "  - $(basename "$vsix")"
        done
        return 0
    fi

    for vsix in "${vsix_files[@]}"; do
        local ext_name=$(basename "$vsix" .vsix)
        installing "安装 $ext_name..."
        code --install-extension "$vsix" 2>/dev/null || warning "$ext_name 安装失败"
    done

    success "VSCode 插件安装完成"
}

install_python_libs() {
    print_section 9 "Python 库"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    if ! is_installed pip3 && ! is_installed pip; then
        skip "pip 未安装，跳过 Python 库安装"
        return 0
    fi

    # Python 包统一放在 apps/python/ 目录下（不分架构）
    local python_dir="$APPS_DIR/python"

    if [[ ! -d "$python_dir" ]]; then
        warning "Python 包目录不存在: $python_dir"
        return 0
    fi

    # 检查是否有包文件 (.whl 或 .tar.gz)
    local pkg_files=("$python_dir"/*.whl "$python_dir"/*.tar.gz)
    local has_packages=false
    for f in "${pkg_files[@]}"; do
        if [[ -f "$f" ]]; then
            has_packages=true
            break
        fi
    done

    if ! $has_packages; then
        warning "未找到 Python 包文件 (.whl 或 .tar.gz)"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将从 $python_dir 安装 Python 包"
        return 0
    fi

    installing "正在安装 Python 库 (离线模式)..."

    # 使用 pip 的 --no-index 和 --find-links 进行离线安装
    # 包都在 apps/python/ 目录（不分架构）
    pip3 install --no-index --find-links "$python_dir" pandas numpy matplotlib scipy openpyxl xlrd jupyter markitdown 2>/dev/null || {
        warning "部分 Python 包可能安装失败，尝试逐个安装..."
        for whl in "$python_dir"/*.whl; do
            [[ -f "$whl" ]] && pip3 install --no-index "$whl" 2>/dev/null || warning "$(basename "$whl") 安装失败"
        done
    }

    success "Python 库安装完成"
}

install_skills() {
    print_section 10 "Claude Code Skills"

    if $SKIP_SKILLS; then
        skip "用户选择跳过"
        return 0
    fi

    local skills_dir="$APPS_DIR/skills"

    if [[ ! -d "$skills_dir" ]]; then
        warning "Skills 目录不存在: $skills_dir"
        return 0
    fi

    # 安装 Anthropic 官方 Skills
    local anthropic_skills="$skills_dir/anthropics-skills"
    if [[ -d "$anthropic_skills" ]]; then
        if $DRY_RUN; then
            info "[DRY-RUN] 将安装 Anthropic Skills 到 ~/.claude/skills/"
        else
            installing "正在安装 Anthropic Skills..."
            mkdir -p "$HOME/.claude/skills"
            cp -r "$anthropic_skills"/* "$HOME/.claude/skills/" 2>/dev/null || true
            success "Anthropic Skills 已安装"
        fi
    else
        warning "未找到 Anthropic Skills: $anthropic_skills"
    fi

    # 安装 SYSU Awesome CC
    local sysu_cc="$skills_dir/sysu-awesome-cc"
    if [[ -d "$sysu_cc" ]]; then
        if $DRY_RUN; then
            info "[DRY-RUN] 将安装 SYSU Awesome CC:"
            echo "  - agents/  -> ~/.claude/agents/"
            echo "  - skills/  -> ~/.claude/skills/"
            echo "  - commands/ -> ~/.claude/commands/"
        else
            installing "正在安装 SYSU Awesome CC..."

            mkdir -p "$HOME/.claude/agents"
            mkdir -p "$HOME/.claude/skills"
            mkdir -p "$HOME/.claude/commands"

            [[ -d "$sysu_cc/agents" ]] && cp -r "$sysu_cc/agents/"* "$HOME/.claude/agents/" 2>/dev/null || true
            [[ -d "$sysu_cc/skills" ]] && cp -r "$sysu_cc/skills/"* "$HOME/.claude/skills/" 2>/dev/null || true
            [[ -d "$sysu_cc/commands" ]] && cp -r "$sysu_cc/commands/"* "$HOME/.claude/commands/" 2>/dev/null || true

            # 创建安装标记
            echo "Installed offline from skills/sysu-awesome-cc" > "$HOME/.claude/.sysu-awesome-cc-installed"
            echo "Date: $(date)" >> "$HOME/.claude/.sysu-awesome-cc-installed"

            success "SYSU Awesome CC 已安装"
        fi
    else
        warning "未找到 SYSU Awesome CC: $sysu_cc"
    fi
}

# ══════════════════════════════════════════════════════════════
# 最终验证
# ══════════════════════════════════════════════════════════════

verify_installation() {
    echo ""
    echo -e "${BOLD}已安装工具:${NC}"

    # 检查 Xcode CLT
    if xcode-select -p &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Xcode CLT: $(xcode-select -p)"
    else
        echo -e "  ${RED}✗${NC} Xcode CLT: 未安装"
    fi

    # 检查命令行工具
    local tools=(
        "code:VSCode"
        "claude:Claude Code"
        "opencode:OpenCode"
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

    # 检查 GUI 应用
    local apps=(
        "Visual Studio Code"
        "CC-Switch"
        "Clash Verge"
    )

    for app in "${apps[@]}"; do
        if is_app_installed "$app"; then
            echo -e "  ${GREEN}✓${NC} $app: installed"
        else
            echo -e "  ${RED}✗${NC} $app: 未安装"
        fi
    done

    # 检查 Claude Code Skills (仅在未跳过时显示)
    if ! $SKIP_SKILLS; then
        echo ""
        echo -e "${BOLD}已安装 Skills:${NC}"

        if [[ -d "$HOME/.claude/skills" && -n "$(ls -A "$HOME/.claude/skills" 2>/dev/null)" ]]; then
            echo -e "  ${GREEN}✓${NC} Skills 目录存在"
        else
            echo -e "  ${RED}✗${NC} Skills: 未安装"
        fi

        if [[ -f "$HOME/.claude/.sysu-awesome-cc-installed" ]]; then
            echo -e "  ${GREEN}✓${NC} SYSU Awesome CC"
            [[ -d "$HOME/.claude/agents" ]] && echo -e "      └─ agents/"
            [[ -d "$HOME/.claude/skills" ]] && echo -e "      └─ skills/"
            [[ -d "$HOME/.claude/commands" ]] && echo -e "      └─ commands/"
        fi
    fi
}

print_next_steps() {
    echo ""
    echo -e "${BOLD}下一步:${NC}"
    echo "  1. 如需安装 Homebrew 和命令行工具，请联网后运行:"
    echo -e "     ${CYAN}../install_ai_tools.sh${NC}  (或从项目根目录运行 ./install_ai_tools.sh)"
    echo "  2. 打开 CC-Switch 应用配置 API 密钥"
    echo "  3. 或运行 'claude login' 登录 Anthropic 账号"
    echo "  4. 运行 'opencode' 或 'claude' 开始使用"
    echo ""
    echo -e "安装日志已保存到: ${CYAN}$LOG_FILE${NC}"
}

# ══════════════════════════════════════════════════════════════
# 主流程
# ══════════════════════════════════════════════════════════════

TOTAL_STEPS=10

main() {
    # 初始化日志
    echo "========================================" >> "$LOG_FILE"
    log "离线安装开始"

    # 系统检测
    detect_system

    # 显示头部
    print_header

    if $DRY_RUN; then
        echo -e "${YELLOW}[预览模式] 以下操作不会实际执行${NC}"
        echo ""
    fi

    info "系统架构: $ARCH_NAME"
    info "离线包目录: $APPS_DIR"

    # 检查离线包目录
    check_apps_dir

    # 执行安装
    install_xcode_clt            # 1 - Xcode Command Line Tools (最先安装)
    install_homebrew_notice      # 2 - 提示 Homebrew 需要网络
    install_vscode               # 3 - Visual Studio Code
    install_claude_code          # 4 - Claude Code
    install_opencode             # 5 - OpenCode
    install_cc_switch            # 6 - CC-Switch
    install_clash_verge          # 7 - Clash Verge Rev
    install_vscode_extensions    # 8 - VSCode 插件
    install_python_libs          # 9 - Python 库
    install_skills               # 10 - Claude Code Skills

    # 显示结果
    print_footer
    verify_installation
    print_next_steps

    log "离线安装完成"
}

# 运行主流程
main
