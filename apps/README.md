# 🖥️ macOS AI 工具套装 - 离线安装包

> 📦 本目录包含 macOS AI 开发工具套装的离线安装资源，支持在无网络环境下快速部署 AI 开发环境。

---

## 📂 目录结构

```
apps/
├── 📄 README.md                      # 本文件
├── 🚀 install_ai_tools_offline.sh    # 离线安装脚本
├── 🔧 xcode-clt/                     # Xcode Command Line Tools (需手动下载)
├── 💻 casks/                 # GUI 应用程序
│   ├── visual-studio-code/
│   │   ├── arm64/            # Apple Silicon 版本
│   │   └── x86_64/           # Intel 版本
│   ├── claude-code/
│   │   ├── arm64/
│   │   └── x86_64/
│   ├── cc-switch/
│   │   ├── arm64/
│   │   ├── x86_64/
│   │   └── universal/
│   ├── opencode/
│   │   ├── arm64/
│   │   └── x86_64/
│   └── clash-verge-rev/
│       ├── arm64/
│       └── x86_64/
├── 🧩 vscode-extensions/     # VSCode 插件 (.vsix 文件)
├── 🐍 python/                # Python wheels 包（不分架构）
└── ⚡ skills/                 # Claude Code Skills
    ├── anthropics-skills/    # 官方 Skills
    └── sysu-awesome-cc/      # 社区 Skills
```

---

## 🚀 使用步骤

### 步骤 1️⃣：下载所有工具

在有网络的机器上，从项目根目录运行：

```bash
./download_tools.sh                   # 下载双架构
./download_tools.sh --arch arm64      # 仅 Apple Silicon
./download_tools.sh --arch x86_64     # 仅 Intel
```

### 步骤 2️⃣：手动下载 Xcode CLT（可选）

如果目标机器完全无网络，需要手动下载 Xcode Command Line Tools：

1. 🌐 访问 [Apple Developer Downloads](https://developer.apple.com/download/all/)
2. 🔐 使用 Apple ID 登录
3. 🔍 搜索 "**Command Line Tools**"
4. ⬇️ 下载对应 macOS 版本的 `.pkg` 文件
5. 📁 将下载的文件保存到 `apps/xcode-clt/` 目录

### 步骤 3️⃣：复制到目标机器

将整个项目目录（或至少 `apps/` 目录）复制到目标 Mac：

```bash
# 使用 U 盘、移动硬盘或局域网传输
cp -r AI工具安装配置/ /Volumes/USB/
# 或只复制 apps 目录
cp -r apps/ /Volumes/USB/
```

### 步骤 4️⃣：运行离线安装

在目标机器上执行（离线安装脚本已移至 apps/ 目录内）：

```bash
# 从项目根目录运行
./apps/install_ai_tools_offline.sh

# 或进入 apps 目录后运行
cd apps && ./install_ai_tools_offline.sh
```

---

## 📖 脚本使用说明

### 下载脚本（位于项目根目录）

```bash
# 查看帮助
./download_tools.sh --help

# 下载所有工具（双架构）
./download_tools.sh

# 仅下载特定架构
./download_tools.sh --arch arm64      # Apple Silicon
./download_tools.sh --arch x86_64     # Intel
```

### 离线安装脚本（位于 apps/ 目录内）

```bash
# 查看帮助
./install_ai_tools_offline.sh --help

# 基础安装（不含 Skills）
./install_ai_tools_offline.sh

# 完整安装（含 Skills）
./install_ai_tools_offline.sh --with-skills

# 跳过特定组件
./install_ai_tools_offline.sh --skip-vscode
./install_ai_tools_offline.sh --skip-python

# 预览模式（不实际执行）
./install_ai_tools_offline.sh --dry-run
```

---

## ⚠️ 注意事项

| 项目 | 说明 |
|------|------|
| 🍺 **Homebrew** | 仍需网络安装（官方不提供离线包） |
| 📦 **Homebrew Formulae** | 依赖 Homebrew，需网络环境 |
| 🏗️ **双架构支持** | `arm64` 用于 Apple Silicon (M1/M2/M3/M4)，`x86_64` 用于 Intel Mac |
| 💾 **预计大小** | 总下载大小约 **1.5GB** |
| 🔄 **版本更新** | 重新运行 `download_tools.sh` 获取最新版本 |

---

## 🏷️ 架构说明

| 架构 | 适用设备 |
|------|----------|
| `arm64` | 🍎 Mac mini M1/M2/M4, MacBook Air/Pro M1/M2/M3/M4, iMac M1/M3/M4, Mac Studio M1/M2 |
| `x86_64` | 💻 2020 年及更早的 Intel Mac |

查看当前 Mac 架构：

```bash
uname -m
# arm64 = Apple Silicon
# x86_64 = Intel
```

---

## 📞 问题反馈

如遇到问题，请检查：

1. ✅ 目标 macOS 版本是否兼容
2. ✅ 架构是否匹配（arm64/x86_64）
3. ✅ 磁盘空间是否充足（建议预留 5GB）
4. ✅ 是否有管理员权限

---

*📅 最后更新：2026-01-30*

> 📝 **变更记录**: `install_ai_tools_offline.sh` 已移至 `apps/` 目录内，与离线资源放在一起，便于整体复制和部署。
