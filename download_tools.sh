#!/bin/bash
#
# macOS AI 工具套装离线下载脚本 v1.0
# 作者: Claude Code for Professor Xueheng Li
# 日期: 2026-01-30
#
# 用法: ./download_tools.sh [选项]
#   --arch arm64       下载 arm64 架构
#   --arch x86_64      下载 x86_64 架构
#   --arch all         下载双架构 (默认)
#   --dry-run          只显示将要执行的操作，不实际执行
#   --skip-casks       跳过 Cask 应用下载
#   --skip-extensions  跳过 VSCode 插件下载
#   --skip-python      跳过 Python wheels 下载
#   --skip-skills      跳过 GitHub 仓库下载
#   --help             显示帮助信息

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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS_DIR="$SCRIPT_DIR/apps"
LOG_FILE="$SCRIPT_DIR/download_tools.log"

# 下载重试次数
MAX_RETRIES=3
RETRY_DELAY=5

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}       macOS AI 工具套装离线下载脚本 v1.0                      ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_footer() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}                       下载完成！                             ${NC}${CYAN}║${NC}"
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
    echo -e "${BLUE}[信息]${NC} $1"
    log "INFO: $1"
}

downloading() {
    echo -e "${CYAN}[下载中]${NC} $1"
    log "DOWNLOADING: $1"
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

skip() {
    echo -e "${YELLOW}[跳过]${NC} $1 ${GREEN}✓${NC}"
    log "SKIP: $1"
}

progress() {
    echo -e "${CYAN}  → ${NC}$1"
}

# 将字节数转换为人类可读格式 (macOS 没有 numfmt)
human_readable_size() {
    local size=$1
    if [[ $size -ge 1073741824 ]]; then
        awk "BEGIN{printf \"%.1fGB\", $size/1073741824}"
    elif [[ $size -ge 1048576 ]]; then
        awk "BEGIN{printf \"%.1fMB\", $size/1048576}"
    elif [[ $size -ge 1024 ]]; then
        awk "BEGIN{printf \"%.1fKB\", $size/1024}"
    else
        echo "${size}B"
    fi
}

# ══════════════════════════════════════════════════════════════
# 命令行参数解析
# ══════════════════════════════════════════════════════════════

ARCH="all"
DRY_RUN=false
SKIP_CASKS=false
SKIP_EXTENSIONS=false
SKIP_PYTHON=false
SKIP_SKILLS=false

show_help() {
    echo "macOS AI 工具套装离线下载脚本 v1.0"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --arch arm64       下载 arm64 架构"
    echo "  --arch x86_64      下载 x86_64 架构"
    echo "  --arch all         下载双架构 (默认)"
    echo "  --dry-run          只显示将要执行的操作，不实际执行"
    echo "  --skip-casks       跳过 Cask 应用下载"
    echo "  --skip-extensions  跳过 VSCode 插件下载"
    echo "  --skip-python      跳过 Python wheels 下载"
    echo "  --skip-skills      跳过 GitHub 仓库下载"
    echo "  --help             显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                      # 下载双架构所有内容"
    echo "  $0 --arch arm64         # 只下载 arm64"
    echo "  $0 --dry-run            # 预览模式"
    echo "  $0 --skip-python        # 跳过 Python wheels"
    echo ""
    echo "目录结构:"
    echo "  apps/"
    echo "  ├── casks/"
    echo "  │   ├── visual-studio-code/{arm64,x86_64}/"
    echo "  │   ├── claude-code/{arm64,x86_64}/"
    echo "  │   ├── cc-switch/{arm64,x86_64}/"
    echo "  │   ├── opencode/{arm64,x86_64}/"
    echo "  │   └── clash-verge-rev/{arm64,x86_64}/"
    echo "  ├── xcode-clt/     (手动下载 .pkg)"
    echo "  ├── vscode-extensions/"
    echo "  ├── python/"
    echo "  └── skills/"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --arch)
            ARCH="$2"
            if [[ "$ARCH" != "arm64" && "$ARCH" != "x86_64" && "$ARCH" != "all" ]]; then
                echo "错误: --arch 参数必须是 arm64, x86_64 或 all"
                exit 1
            fi
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-casks)
            SKIP_CASKS=true
            shift
            ;;
        --skip-extensions)
            SKIP_EXTENSIONS=true
            shift
            ;;
        --skip-python)
            SKIP_PYTHON=true
            shift
            ;;
        --skip-skills)
            SKIP_SKILLS=true
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
# 工具函数
# ══════════════════════════════════════════════════════════════

# 检测是否需要下载指定架构
should_download_arch() {
    local arch="$1"
    [[ "$ARCH" == "all" || "$ARCH" == "$arch" ]]
}

# 带重试的下载函数
download_with_retry() {
    local url="$1"
    local output="$2"
    local description="$3"

    if [[ -f "$output" ]]; then
        skip "已存在: $description"
        return 0
    fi

    if $DRY_RUN; then
        info "[DRY-RUN] 将下载: $description"
        info "  URL: $url"
        info "  输出: $output"
        return 0
    fi

    local retry=0
    while [[ $retry -lt $MAX_RETRIES ]]; do
        downloading "$description (尝试 $((retry+1))/$MAX_RETRIES)"

        # 使用 curl 下载，支持重定向，显示进度
        if curl -L --connect-timeout 30 --max-time 600 --retry 3 \
                --progress-bar -o "$output" "$url"; then
            # 验证文件大小
            local size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)
            if [[ -n "$size" && "$size" -gt 0 ]]; then
                success "$description ($(human_readable_size $size))"
                return 0
            else
                warning "下载的文件为空: $description"
                rm -f "$output"
            fi
        fi

        retry=$((retry + 1))
        if [[ $retry -lt $MAX_RETRIES ]]; then
            warning "下载失败，${RETRY_DELAY}秒后重试..."
            sleep $RETRY_DELAY
        fi
    done

    error "下载失败: $description"
    return 1
}

# 创建目录
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log "创建目录: $dir"
    fi
}

# 验证下载完整性 (检查文件是否为有效格式)
verify_download() {
    local file="$1"
    local type="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    case "$type" in
        zip)
            unzip -t "$file" &>/dev/null
            ;;
        dmg)
            # DMG 文件头部检查
            file "$file" | grep -q "Apple Disk Image"
            ;;
        tar.gz)
            tar -tzf "$file" &>/dev/null
            ;;
        vsix)
            # VSIX 是 ZIP 格式
            unzip -t "$file" &>/dev/null
            ;;
        binary)
            # 检查是否是可执行文件
            file "$file" | grep -qE "(Mach-O|executable)"
            ;;
        *)
            # 默认检查文件大小
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            [[ -n "$size" && "$size" -gt 1000 ]]
            ;;
    esac
}

# ══════════════════════════════════════════════════════════════
# 下载函数
# ══════════════════════════════════════════════════════════════

download_vscode() {
    local cask_dir="$APPS_DIR/casks/visual-studio-code"

    if should_download_arch "arm64"; then
        ensure_dir "$cask_dir/arm64"
        download_with_retry \
            "https://update.code.visualstudio.com/latest/darwin-arm64/stable" \
            "$cask_dir/arm64/VSCode-darwin-arm64.zip" \
            "Visual Studio Code (arm64)"
    fi

    if should_download_arch "x86_64"; then
        ensure_dir "$cask_dir/x86_64"
        download_with_retry \
            "https://update.code.visualstudio.com/latest/darwin/stable" \
            "$cask_dir/x86_64/VSCode-darwin-x64.zip" \
            "Visual Studio Code (x86_64)"
    fi
}

download_claude_code() {
    local cask_dir="$APPS_DIR/casks/claude-code"
    local base_url="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

    # 获取最新版本号
    info "获取 Claude Code 最新版本..."
    local CC_VERSION=$(curl -sL "${base_url}/latest")
    if [[ -z "$CC_VERSION" ]]; then
        error "无法获取 Claude Code 版本号"
        return 1
    fi
    info "Claude Code 版本: $CC_VERSION"

    if should_download_arch "arm64"; then
        ensure_dir "$cask_dir/arm64"
        download_with_retry \
            "${base_url}/${CC_VERSION}/darwin-arm64/claude" \
            "$cask_dir/arm64/claude-darwin-arm64" \
            "Claude Code (arm64)"
    fi

    if should_download_arch "x86_64"; then
        ensure_dir "$cask_dir/x86_64"
        download_with_retry \
            "${base_url}/${CC_VERSION}/darwin-x64/claude" \
            "$cask_dir/x86_64/claude-darwin-x64" \
            "Claude Code (x86_64)"
    fi
}

download_cc_switch() {
    local cask_dir="$APPS_DIR/casks/cc-switch"

    # 获取最新版本号
    info "获取 CC-Switch 最新版本..."
    local CCS_VERSION=$(curl -s "https://api.github.com/repos/farion1231/cc-switch/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$CCS_VERSION" ]]; then
        error "无法获取 CC-Switch 版本号"
        return 1
    fi
    info "CC-Switch 版本: $CCS_VERSION"

    local base_url="https://github.com/farion1231/cc-switch/releases/download/${CCS_VERSION}"

    # CC-Switch 现在只有 universal zip 版本
    ensure_dir "$cask_dir/universal"
    download_with_retry \
        "${base_url}/CC-Switch-${CCS_VERSION}-macOS.zip" \
        "$cask_dir/universal/CC-Switch-${CCS_VERSION}-macOS.zip" \
        "CC-Switch (universal)"
}

download_opencode() {
    local cask_dir="$APPS_DIR/casks/opencode"

    # 获取最新版本号
    info "获取 OpenCode 最新版本..."
    local OC_VERSION=$(curl -s "https://api.github.com/repos/opencode-ai/opencode/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$OC_VERSION" ]]; then
        error "无法获取 OpenCode 版本号"
        return 1
    fi
    info "OpenCode 版本: $OC_VERSION"

    local base_url="https://github.com/opencode-ai/opencode/releases/download/${OC_VERSION}"

    if should_download_arch "arm64"; then
        ensure_dir "$cask_dir/arm64"
        download_with_retry \
            "${base_url}/opencode-mac-arm64.tar.gz" \
            "$cask_dir/arm64/opencode-mac-arm64.tar.gz" \
            "OpenCode (arm64)"
    fi

    if should_download_arch "x86_64"; then
        ensure_dir "$cask_dir/x86_64"
        download_with_retry \
            "${base_url}/opencode-mac-x86_64.tar.gz" \
            "$cask_dir/x86_64/opencode-mac-x86_64.tar.gz" \
            "OpenCode (x86_64)"
    fi
}

download_clash_verge_rev() {
    local cask_dir="$APPS_DIR/casks/clash-verge-rev"

    # 获取最新版本号
    info "获取 Clash Verge Rev 最新版本..."
    local CVR_VERSION=$(curl -s "https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$CVR_VERSION" ]]; then
        error "无法获取 Clash Verge Rev 版本号"
        return 1
    fi
    info "Clash Verge Rev 版本: $CVR_VERSION"

    # 去掉 v 前缀获取版本号
    local VERSION_NUM=${CVR_VERSION#v}
    local base_url="https://github.com/clash-verge-rev/clash-verge-rev/releases/download/${CVR_VERSION}"

    if should_download_arch "arm64"; then
        ensure_dir "$cask_dir/arm64"
        download_with_retry \
            "${base_url}/Clash.Verge_${VERSION_NUM}_aarch64.dmg" \
            "$cask_dir/arm64/Clash.Verge_${VERSION_NUM}_aarch64.dmg" \
            "Clash Verge Rev (arm64)"
    fi

    if should_download_arch "x86_64"; then
        ensure_dir "$cask_dir/x86_64"
        download_with_retry \
            "${base_url}/Clash.Verge_${VERSION_NUM}_x64.dmg" \
            "$cask_dir/x86_64/Clash.Verge_${VERSION_NUM}_x64.dmg" \
            "Clash Verge Rev (x86_64)"
    fi
}

download_casks() {
    print_section 1 "Cask 应用 (VSCode, Claude Code, CC-Switch, OpenCode, Clash Verge)"

    if $SKIP_CASKS; then
        skip "用户选择跳过"
        return 0
    fi

    info "目标架构: $ARCH"

    download_vscode
    download_claude_code
    download_cc_switch
    download_opencode
    download_clash_verge_rev

    success "Cask 应用下载完成"
}

download_vscode_extensions() {
    print_section 2 "VSCode 插件"

    if $SKIP_EXTENSIONS; then
        skip "用户选择跳过"
        return 0
    fi

    local ext_dir="$APPS_DIR/vscode-extensions"
    ensure_dir "$ext_dir"

    # VSCode 插件列表 (publisher.extension-name)
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

    for ext in "${extensions[@]}"; do
        # 解析 publisher 和 extension name
        local publisher="${ext%%.*}"
        local extension="${ext#*.}"

        local output_file="$ext_dir/${ext}.vsix"

        # VSCode Marketplace API URL
        local url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${publisher}/vsextensions/${extension}/latest/vspackage"

        download_with_retry "$url" "$output_file" "VSCode 插件: $ext"
    done

    success "VSCode 插件下载完成"
}

download_python_packages() {
    print_section 3 "Python Wheels"

    if $SKIP_PYTHON; then
        skip "用户选择跳过"
        return 0
    fi

    local python_dir="$APPS_DIR/python"
    ensure_dir "$python_dir"

    local packages=(
        "pandas"
        "numpy"
        "matplotlib"
        "scipy"
        "openpyxl"
        "xlrd"
        "jupyter"
        "markitdown"
    )

    if $DRY_RUN; then
        info "[DRY-RUN] 将下载 Python 包: ${packages[*]}"
        info "  输出目录: $python_dir"
        return 0
    fi

    downloading "Python 包 (${packages[*]})"

    # 检查是否有 pip
    if command -v pip3 &>/dev/null || command -v pip &>/dev/null; then
        local pip_cmd="pip3"
        command -v pip3 &>/dev/null || pip_cmd="pip"

        info "使用 pip 下载 Python 包 (仅二进制 wheels)..."

        # 直接下载到 python 目录，不限制平台
        $pip_cmd download "${packages[@]}" \
            -d "$python_dir" \
            --only-binary=:all: 2>&1 || warning "部分包下载失败"

    else
        warning "未找到 pip，无法下载 Python 包"
        warning "请先安装 Python: brew install python"
        return 1
    fi

    # 统计下载的包数量
    local count=$(find "$python_dir" -name "*.whl" -o -name "*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
    success "Python 包下载完成 (共 $count 个文件)"
}

download_xcode_clt() {
    print_section 4 "Xcode Command Line Tools"

    local clt_dir="$APPS_DIR/xcode-clt"
    ensure_dir "$clt_dir"

    echo ""
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│  Xcode CLT 需要手动下载                                         │${NC}"
    echo -e "${YELLOW}├────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${YELLOW}│  1. 访问: https://developer.apple.com/download/all/            │${NC}"
    echo -e "${YELLOW}│  2. 搜索 \"Command Line Tools\"                                  │${NC}"
    echo -e "${YELLOW}│  3. 下载对应 macOS 版本的 .pkg 文件                            │${NC}"
    echo -e "${YELLOW}│  4. 保存到: apps/xcode-clt/                                    │${NC}"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────┘${NC}"
    echo ""

    # 检查是否已有下载的文件
    local existing_pkg=$(find "$clt_dir" -name "*.pkg" 2>/dev/null | head -n1)
    if [[ -n "$existing_pkg" ]]; then
        success "已存在离线包: $(basename "$existing_pkg")"
    else
        warning "请手动下载 Xcode CLT 到 apps/xcode-clt/ 目录"
    fi
}

download_github_repos() {
    print_section 5 "GitHub 仓库 (Skills)"

    if $SKIP_SKILLS; then
        skip "用户选择跳过"
        return 0
    fi

    local skills_dir="$APPS_DIR/skills"
    ensure_dir "$skills_dir"

    # 检查 git 是否可用
    if ! command -v git &>/dev/null; then
        warning "git 未安装，无法下载 GitHub 仓库"
        return 1
    fi

    # Anthropic Official Skills
    local anthropics_dir="$skills_dir/anthropics-skills"
    if [[ -d "$anthropics_dir" ]]; then
        skip "已存在: Anthropic Official Skills"
    else
        if $DRY_RUN; then
            info "[DRY-RUN] 将克隆: https://github.com/anthropics/skills"
        else
            downloading "Anthropic Official Skills"
            if git clone --depth 1 https://github.com/anthropics/skills.git "$anthropics_dir" 2>&1; then
                success "Anthropic Official Skills"
            else
                error "克隆 Anthropic Skills 失败"
            fi
        fi
    fi

    # SYSU Awesome CC
    local sysu_dir="$skills_dir/sysu-awesome-cc"
    if [[ -d "$sysu_dir" ]]; then
        skip "已存在: SYSU Awesome CC"
    else
        if $DRY_RUN; then
            info "[DRY-RUN] 将克隆: https://github.com/Xueheng-Li/sysu-awesome-cc"
        else
            downloading "SYSU Awesome CC"
            if git clone --depth 1 https://github.com/Xueheng-Li/sysu-awesome-cc.git "$sysu_dir" 2>&1; then
                success "SYSU Awesome CC"
            else
                error "克隆 SYSU Awesome CC 失败"
            fi
        fi
    fi

    success "GitHub 仓库下载完成"
}

# ══════════════════════════════════════════════════════════════
# 验证和汇总
# ══════════════════════════════════════════════════════════════

verify_downloads() {
    echo ""
    echo -e "${BOLD}下载内容汇总:${NC}"
    echo ""

    # Cask 应用
    echo -e "${CYAN}Cask 应用:${NC}"
    local cask_dir="$APPS_DIR/casks"
    if [[ -d "$cask_dir" ]]; then
        for cask in visual-studio-code claude-code cc-switch opencode clash-verge-rev; do
            local cask_path="$cask_dir/$cask"
            if [[ -d "$cask_path" ]]; then
                local files=$(find "$cask_path" -type f 2>/dev/null | wc -l | tr -d ' ')
                echo -e "  ${GREEN}✓${NC} $cask ($files 个文件)"
                # 列出各架构
                for arch_dir in "$cask_path"/*; do
                    if [[ -d "$arch_dir" ]]; then
                        local arch_name=$(basename "$arch_dir")
                        local arch_files=$(ls "$arch_dir" 2>/dev/null | head -3 | tr '\n' ', ' | sed 's/,$//')
                        echo -e "      └─ $arch_name: $arch_files"
                    fi
                done
            else
                echo -e "  ${RED}✗${NC} $cask (未下载)"
            fi
        done
    else
        echo -e "  ${RED}✗${NC} Cask 目录不存在"
    fi

    echo ""

    # VSCode 插件
    echo -e "${CYAN}VSCode 插件:${NC}"
    local ext_dir="$APPS_DIR/vscode-extensions"
    if [[ -d "$ext_dir" ]]; then
        local ext_count=$(find "$ext_dir" -name "*.vsix" 2>/dev/null | wc -l | tr -d ' ')
        echo -e "  ${GREEN}✓${NC} $ext_count 个插件"
        find "$ext_dir" -name "*.vsix" -exec basename {} \; 2>/dev/null | while read f; do
            echo -e "      └─ $f"
        done
    else
        echo -e "  ${RED}✗${NC} 未下载"
    fi

    echo ""

    # Python 包
    echo -e "${CYAN}Python Wheels:${NC}"
    local python_dir="$APPS_DIR/python"
    if [[ -d "$python_dir" ]]; then
        local wheel_count=$(find "$python_dir" -name "*.whl" 2>/dev/null | wc -l | tr -d ' ')
        local tarball_count=$(find "$python_dir" -name "*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
        local total_size=$(du -sh "$python_dir" 2>/dev/null | cut -f1)
        echo -e "  ${GREEN}✓${NC} $wheel_count 个 wheel, $tarball_count 个 tarball (共 $total_size)"
    else
        echo -e "  ${RED}✗${NC} 未下载"
    fi

    echo ""

    # Xcode CLT
    echo -e "${CYAN}Xcode Command Line Tools:${NC}"
    local clt_dir="$APPS_DIR/xcode-clt"
    if [[ -d "$clt_dir" ]]; then
        local pkg_count=$(find "$clt_dir" -name "*.pkg" 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$pkg_count" -gt 0 ]]; then
            echo -e "  ${GREEN}✓${NC} $pkg_count 个 .pkg 文件"
            find "$clt_dir" -name "*.pkg" -exec basename {} \; 2>/dev/null | while read f; do
                echo -e "      └─ $f"
            done
        else
            echo -e "  ${YELLOW}!${NC} 需要手动下载 (目录已创建)"
        fi
    else
        echo -e "  ${RED}✗${NC} 目录不存在"
    fi

    echo ""

    # GitHub 仓库
    echo -e "${CYAN}GitHub 仓库:${NC}"
    local skills_dir="$APPS_DIR/skills"
    if [[ -d "$skills_dir/anthropics-skills" ]]; then
        echo -e "  ${GREEN}✓${NC} anthropics/skills"
    else
        echo -e "  ${RED}✗${NC} anthropics/skills (未下载)"
    fi
    if [[ -d "$skills_dir/sysu-awesome-cc" ]]; then
        echo -e "  ${GREEN}✓${NC} sysu-awesome-cc"
    else
        echo -e "  ${RED}✗${NC} sysu-awesome-cc (未下载)"
    fi

    echo ""

    # 总大小
    if [[ -d "$APPS_DIR" ]]; then
        local total_size=$(du -sh "$APPS_DIR" 2>/dev/null | cut -f1)
        echo -e "${BOLD}总大小: ${CYAN}$total_size${NC}"
    fi
}

print_next_steps() {
    echo ""
    echo -e "${BOLD}下一步:${NC}"
    echo "  1. 将 apps/ 目录复制到目标机器"
    echo "  2. 运行离线安装脚本: ./install_offline.sh"
    echo ""
    echo -e "下载日志已保存到: ${CYAN}$LOG_FILE${NC}"
    echo -e "下载目录: ${CYAN}$APPS_DIR${NC}"
}

# ══════════════════════════════════════════════════════════════
# 主流程
# ══════════════════════════════════════════════════════════════

TOTAL_STEPS=5

main() {
    # 初始化日志
    echo "========================================" >> "$LOG_FILE"
    log "下载开始 - 架构: $ARCH"

    # 显示头部
    print_header

    if $DRY_RUN; then
        echo -e "${YELLOW}[预览模式] 以下操作不会实际执行${NC}"
        echo ""
    fi

    info "目标架构: $ARCH"
    info "下载目录: $APPS_DIR"

    # 创建根目录
    ensure_dir "$APPS_DIR"

    # 执行下载
    download_casks
    download_vscode_extensions
    download_python_packages
    download_xcode_clt
    download_github_repos

    # 显示结果
    print_footer

    if ! $DRY_RUN; then
        verify_downloads
    fi

    print_next_steps

    log "下载完成"
}

# 运行主流程
main
