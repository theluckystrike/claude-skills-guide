---
title: "Claude Code安装教程：完整指南 (2026)"
description: "Claude Code安装完整教程，从Node.js环境准备到npm全局安装命令，涵盖API密钥配置（Anthropic直连、Bedrock、Vertex），常见安装错误EACCES权限不足和网络超时的排查，以及安装后验证步骤，一步步带你在macOS、Linux和WSL2上完成Claude Code的安装。"
permalink: /claude-code-anzhuang-installation-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Claude Code安装教程：完整指南 (2026)

Claude Code是Anthropic推出的命令行AI编程助手，能够直接在你的终端中提供代码编写、调试和项目管理等功能。本文将详细介绍如何在你的电脑上完成Claude Code的安装，涵盖环境准备、安装步骤、API密钥配置以及常见问题的解决方案。

## 安装前的环境准备

在安装Claude Code之前，你需要确保系统满足以下基本要求。

### Node.js版本要求

Claude Code需要Node.js 18或更高版本。你可以通过以下命令检查当前安装的Node.js版本：

```bash
node --version
```

如果输出的版本号低于v18.0.0，或者系统提示未找到node命令，你需要先安装或升级Node.js。

#### 安装Node.js的推荐方式

**方式一：使用nvm（推荐）**

nvm（Node Version Manager）是管理Node.js版本的最佳工具，支持在多个版本间轻松切换：

```bash
# 安装nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 重新加载shell配置
source ~/.bashrc  # 如果使用bash
source ~/.zshrc   # 如果使用zsh

# 安装最新LTS版本的Node.js
nvm install --lts

# 验证安装
node --version
```

**方式二：直接从官网下载**

访问 [Node.js官网](https://nodejs.org/) 下载最新的LTS版本安装包，按照安装向导完成安装即可。

**方式三：使用Homebrew（macOS）**

```bash
brew install node
```

### npm版本要求

Claude Code通过npm进行安装。npm通常随Node.js一起安装。确认npm可用：

```bash
npm --version
```

建议使用npm 9.0或更高版本。如果需要更新npm：

```bash
npm install -g npm@latest
```

### 操作系统支持

Claude Code支持以下操作系统：

| 操作系统 | 支持状态 | 备注 |
|---------|---------|------|
| macOS 12+ | 完全支持 | 推荐使用 |
| Ubuntu 20.04+ | 完全支持 | 包括WSL2 |
| Debian 11+ | 完全支持 | — |
| Windows | 通过WSL2支持 | 需要先安装WSL2 |

Windows用户需要先安装WSL2（Windows Subsystem for Linux），然后在WSL2环境中安装Claude Code。原生Windows命令行暂不支持。

## 安装Claude Code

满足环境要求后，使用以下命令安装Claude Code。更多关于安装流程的说明也可以参考我们的[英文安装指南](/claude-code-process-exited-code-1-fix/)。

### 全局安装（推荐）

```bash
npm install -g @anthropic-ai/claude-code
```

全局安装后，你可以在任何目录下直接使用`claude`命令。

### 验证安装成功

安装完成后，运行以下命令验证：

```bash
claude --version
```

如果看到版本号输出（例如`1.0.34`），说明安装成功。

### 首次启动

在你的项目目录中运行：

```bash
cd /你的项目路径
claude
```

首次启动时，Claude Code会引导你完成API密钥的配置。

## API密钥配置

Claude Code需要一个有效的API密钥才能工作。你有几种选择来提供API访问。

### 方式一：Anthropic API密钥（直接方式）

1. 访问 [Anthropic Console](https://console.anthropic.com/) 注册或登录
2. 在API Keys页面创建新的密钥
3. 复制生成的密钥（格式为`sk-ant-...`）

在终端中设置环境变量：

```bash
export ANTHROPIC_API_KEY="sk-ant-你的密钥"
```

为了持久保存，将上面这行添加到你的shell配置文件中：

```bash
# bash用户
echo 'export ANTHROPIC_API_KEY="sk-ant-你的密钥"' >> ~/.bashrc

# zsh用户
echo 'export ANTHROPIC_API_KEY="sk-ant-你的密钥"' >> ~/.zshrc
```

### 方式二：通过Amazon Bedrock使用

如果你的团队使用AWS，可以通过Amazon Bedrock访问Claude模型：

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID="你的AWS访问密钥"
export AWS_SECRET_ACCESS_KEY="你的AWS秘密密钥"
```

### 方式三：通过Google Vertex AI使用

如果使用GCP，可以通过Vertex AI访问：

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID="你的GCP项目ID"
```

关于不同接入方式的费用对比，请参考我们的[Claude Code费用完整指南](/claude-code-cost-complete-guide/)。

## 常见安装错误及解决方案

安装过程中可能遇到各种问题。以下是最常见的错误及其解决方法。如果你遇到了退出码为1的错误，我们有一篇[专门的故障排除指南](/claude-code-process-exited-code-1-fix/)可以参考。

### 错误一：EACCES权限不足

```
npm ERR! Error: EACCES: permission denied
```

**不要使用sudo安装**。正确的做法是修复npm全局目录的权限：

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 重新安装
npm install -g @anthropic-ai/claude-code
```

### 错误二：Node.js版本过低

```
error engine: Unsupported engine
```

升级Node.js到18或更高版本：

```bash
nvm install --lts
nvm use --lts
```

### 错误三：网络连接超时

```
npm ERR! network timeout
```

如果你在[Claude Code 国内使用指南](/claude-code-guonei-shiyong-china-usage-guide/)网络环境下安装，可能需要配置npm镜像或使用代理：

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 安装完成后恢复
npm config set registry https://registry.npmjs.org
```

如果需要使用代理：

```bash
npm config set proxy http://127.0.0.1:7890
npm config set https-proxy http://127.0.0.1:7890
```

### 错误四：zsh: command not found: claude

安装完成但无法找到claude命令。这通常是PATH配置问题：

```bash
# 查看npm全局bin目录
npm bin -g

# 确保该目录在PATH中
echo 'export PATH=$(npm bin -g):$PATH' >> ~/.zshrc
source ~/.zshrc
```

更多关于这个问题的详细解决方案，请参考[zsh command not found claude修复指南](/zsh-command-not-found-claude-fix/)。

### 错误五：SSL证书错误

在某些企业网络环境下可能遇到SSL相关错误：

```bash
npm config set strict-ssl false  # 仅用于调试，不推荐长期使用
```

## 安装后的验证步骤

安装完成后，建议执行以下验证步骤确保一切正常。

### 检查版本

```bash
claude --version
```

### 检查API连接

```bash
claude "你好，请回复OK"
```

如果收到正常回复，说明API密钥配置正确，网络连接正常。

### 检查可用功能

```bash
claude --help
```

这会显示所有可用的命令行选项和功能。

---

*这些配置模板来自 [Claude Code Playbook](https://zovo.one/pricing) — 包含200个生产就绪模板、权限配置和团队设置指南。*

## 在不同环境中安装

### WSL2环境（Windows用户）

```bash
# 在Windows PowerShell中安装WSL2
wsl --install

# 重启后，在WSL2的Ubuntu终端中
sudo apt update
sudo apt install nodejs npm
npm install -g @anthropic-ai/claude-code
```

### Docker容器中安装

```dockerfile
FROM node:20-slim
RUN npm install -g @anthropic-ai/claude-code
ENV ANTHROPIC_API_KEY=你的密钥
```

### CI/CD环境中使用

在GitHub Actions等CI环境中，可以通过npx临时使用而无需全局安装：

```yaml
- name: Run Claude Code
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  run: npx @anthropic-ai/claude-code "检查代码质量"
```

## 升级Claude Code

Claude Code更新频繁。使用以下命令升级到最新版本：

```bash
npm update -g @anthropic-ai/claude-code
```

或者重新安装：

```bash
npm install -g @anthropic-ai/claude-code@latest
```

建议定期更新以获取最新功能和修复。

## 卸载Claude Code

如果需要卸载：

```bash
npm uninstall -g @anthropic-ai/claude-code
```

同时清理配置文件：

```bash
rm -rf ~/.claude
```

## 总结

Claude Code的安装过程相对简单：确保Node.js 18+环境就绪，通过npm全局安装，配置API密钥即可开始使用。遇到问题时，大多数错误都与Node.js版本、网络连接或权限配置有关，按照上述解决方案逐一排查即可。

安装完成后，你可以阅读我们的[Claude Code使用教程](/claude-code-shiyong-jiaocheng-tutorial/)来系统学习如何使用Claude Code，或者查看[快捷键指南](/claude-shortcuts-complete-guide/)来提高使用效率。需要扩展功能的话，请参考[MCP配置指南](/claude-code-mcp-configuration-guide/)。更多中文资源请访问[Claude Code中文指南合集](/claude-code-zhongwen-guide/)。



## Related

- [Claude Code使用教程 (Chinese Tutorial)](/claude-code-shiyong-jiaocheng-tutorial/) — Claude Code complete tutorial in Chinese (中文使用教程)
- [Claude Code价格指南 (Chinese Pricing Guide)](/claude-code-jiage-pricing-guide/) — Claude Code pricing guide in Chinese (中文价格教程)
- [Claude Code拼车指南 (Chinese Group Sharing Guide)](/claude-code-pinche-group-sharing/) — Claude Code group sharing and cost optimization in Chinese (中文拼车指南)
- [Claude Code中文指南合集 (Chinese Guide Index)](/claude-code-zhongwen-guide/) — All Chinese guides in one place (中文指南合集)
- [Claude Code价格和费用完整指南 (2026)](/claude-code-jiage-pricing-guide-zh/)
- [Claude Code拼车指南：合租与共享方案 (2026)](/claude-code-pinche-group-sharing-zh/)
- [Claude Code国内使用指南 (2026)](/claude-code-guonei-shiyong-china-usage-guide-zh/)
- [Claude Code中文指南合集 (2026)](/claude-code-zhongwen-guide-zh/)

## 常见问题

### Claude Code支持Windows吗？

Claude Code不支持原生Windows环境。Windows用户需要先安装WSL2（Windows Subsystem for Linux），然后在WSL2中安装Claude Code。

### 安装时可以使用sudo吗？

不建议使用sudo安装。使用sudo npm install -g会创建root权限的文件，导致后续安装出现权限问题。正确做法是修改npm全局目录到用户目录下。

### Claude Code需要多少磁盘空间？

Claude Code本身占用约100-200MB。加上Node.js和npm依赖，总共需要约500MB的可用磁盘空间。

### 可以离线使用Claude Code吗？

不可以。Claude Code需要连接到Anthropic API服务器才能工作。每次使用都需要网络连接。

### 安装后如何更新到最新版本？

运行 npm update -g @anthropic-ai/claude-code 即可更新。建议定期更新以获取最新功能和修复。

### Claude Code和Claude Desktop是同一个东西吗？

不是。Claude Code是命令行工具，在终端中使用。Claude Desktop是图形界面应用程序。两者独立安装和配置。

### 一台电脑可以安装多个版本的Claude Code吗？

不建议这样做。npm全局只能安装一个版本。如果需要测试不同版本，可以使用npx指定版本号运行。

### 安装过程中遇到ETIMEOUT错误怎么办？

这通常是网络问题。检查代理设置是否正确，或尝试使用npm镜像源。详细的网络配置请参考国内使用指南。

### pnpm或yarn可以安装Claude Code吗？

可以，但推荐使用npm以确保一致性。如果使用其他包管理器，需要确保其全局bin目录在PATH中。

### 安装成功但claude命令无法运行怎么办？

这是PATH配置问题。运行npm bin -g查看全局bin目录，然后将该目录添加到PATH环境变量中。

### API密钥存储在哪里？

API密钥通过环境变量ANTHROPIC_API_KEY提供。建议将其添加到shell配置文件中（如~/.zshrc或~/.bashrc），不要硬编码在代码中。

### 安装需要管理员权限吗？

如果使用推荐的npm prefix配置方法，不需要管理员权限。只有在默认的/usr/local目录下安装时才可能需要权限调整。

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Claude Code支持Windows吗？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code不支持原生Windows环境。Windows用户需要先安装WSL2（Windows Subsystem for Linux），然后在WSL2中安装Claude Code。"}},
    {"@type": "Question", "name": "安装时可以使用sudo吗？", "acceptedAnswer": {"@type": "Answer", "text": "不建议使用sudo安装。使用sudo npm install -g会创建root权限的文件，导致后续安装出现权限问题。正确做法是修改npm全局目录到用户目录下。"}},
    {"@type": "Question", "name": "Claude Code需要多少磁盘空间？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code本身占用约100-200MB。加上Node.js和npm依赖，总共需要约500MB的可用磁盘空间。"}},
    {"@type": "Question", "name": "可以离线使用Claude Code吗？", "acceptedAnswer": {"@type": "Answer", "text": "不可以。Claude Code需要连接到Anthropic API服务器才能工作。每次使用都需要网络连接。"}},
    {"@type": "Question", "name": "安装后如何更新到最新版本？", "acceptedAnswer": {"@type": "Answer", "text": "运行 npm update -g @anthropic-ai/claude-code 即可更新。建议定期更新以获取最新功能和修复。"}},
    {"@type": "Question", "name": "Claude Code和Claude Desktop是同一个东西吗？", "acceptedAnswer": {"@type": "Answer", "text": "不是。Claude Code是命令行工具，在终端中使用。Claude Desktop是图形界面应用程序。两者独立安装和配置。"}},
    {"@type": "Question", "name": "一台电脑可以安装多个版本的Claude Code吗？", "acceptedAnswer": {"@type": "Answer", "text": "不建议这样做。npm全局只能安装一个版本。如果需要测试不同版本，可以使用npx指定版本号运行。"}},
    {"@type": "Question", "name": "安装过程中遇到ETIMEOUT错误怎么办？", "acceptedAnswer": {"@type": "Answer", "text": "这通常是网络问题。检查代理设置是否正确，或尝试使用npm镜像源。详细的网络配置请参考国内使用指南。"}},
    {"@type": "Question", "name": "pnpm或yarn可以安装Claude Code吗？", "acceptedAnswer": {"@type": "Answer", "text": "可以，但推荐使用npm以确保一致性。如果使用其他包管理器，需要确保其全局bin目录在PATH中。"}},
    {"@type": "Question", "name": "安装成功但claude命令无法运行怎么办？", "acceptedAnswer": {"@type": "Answer", "text": "这是PATH配置问题。运行npm bin -g查看全局bin目录，然后将该目录添加到PATH环境变量中。"}},
    {"@type": "Question", "name": "API密钥存储在哪里？", "acceptedAnswer": {"@type": "Answer", "text": "API密钥通过环境变量ANTHROPIC_API_KEY提供。建议将其添加到shell配置文件中，不要硬编码在代码中。"}},
    {"@type": "Question", "name": "安装需要管理员权限吗？", "acceptedAnswer": {"@type": "Answer", "text": "如果使用推荐的npm prefix配置方法，不需要管理员权限。只有在默认的/usr/local目录下安装时才可能需要权限调整。"}}
  ]
}
</script>
