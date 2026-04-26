---
layout: default
title: "Claude Code使用教程：从入门到精通 (2026)"
description: "Claude Code使用教程完整指南，从npm安装启动到高级配置，涵盖终端常用命令详解、CLAUDE.md配置文件编写规范、MCP服务器集成方法、多文件操作技巧和中国开发者专属网络建议，附详细代码示例、Sonnet与Opus模型选择、费用优化策略和常见问题解答，适合零基础到进阶用户的全面参考手册。"
permalink: /claude-code-shiyong-jiaocheng-tutorial/
date: 2026-04-20
last_tested: "2026-04-24"
---

# Claude Code使用教程：从入门到精通 (2026)

Claude Code是Anthropic推出的AI命令行编程助手，运行在终端中，能够读取和编辑你的代码文件、执行Shell命令、搜索代码库，并与你进行自然语言对话来完成复杂的开发任务。本教程将从零开始，系统地介绍Claude Code的安装、配置和使用方法，帮助你快速掌握这款工具并将其融入日常开发工作流。

## 什么是Claude Code

Claude Code与传统的代码编辑器插件不同。它不是一个IDE插件，而是一个独立的命令行工具。你在终端中启动它之后，它可以：

- **读取和编辑项目中的文件**：直接修改源代码、配置文件、文档等
- **执行Shell命令**：运行测试、安装依赖、管理Git等
- **搜索代码库**：快速定位函数定义、查找引用、分析代码结构
- **理解项目上下文**：通过读取CLAUDE.md配置文件了解项目的技术栈和规范
- **使用MCP服务器**：连接外部工具和数据源来扩展能力

Claude Code的核心优势在于它能理解整个项目的上下文，而不仅仅是单个文件。这使得它在处理跨文件重构、复杂调试和架构设计等任务时特别高效。

关于Claude Code与其他编程工具的对比，可以参考[Claude Code vs Cursor完整对比](/claude-code-vs-cursor-definitive-comparison-2026/)。

## 安装前提

在开始使用Claude Code之前，你需要完成基础环境的准备。

### 系统要求

| 项目 | 要求 |
|-----|------|
| 操作系统 | macOS 12+, Ubuntu 20.04+, Debian 11+, 或 Windows (WSL2) |
| Node.js | 18.0.0 或更高版本 |
| npm | 9.0 或更高版本 |
| 网络 | 需要连接到Anthropic API |

### 快速检查环境

```bash
# 检查Node.js版本
node --version
# 输出应为 v18.x.x 或更高

# 检查npm版本
npm --version
# 输出应为 9.x.x 或更高
```

如果你的Node.js版本不满足要求，可以使用nvm管理版本：

```bash
# 安装nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 安装最新LTS版本
nvm install --lts
nvm use --lts
```

### 安装Claude Code

```bash
# 全局安装（推荐）
npm install -g @anthropic-ai/claude-code

# 验证安装
claude --version
```

详细的安装步骤和常见安装错误的解决方案，请参考[Claude Code安装教程](/claude-code-anzhuang-installation-guide/)。

### 配置API密钥

Claude Code需要API密钥才能工作。最简单的方式是设置环境变量：

```bash
# 方式一：Anthropic API密钥
export ANTHROPIC_API_KEY="sk-ant-你的密钥"

# 持久保存到shell配置
echo 'export ANTHROPIC_API_KEY="sk-ant-你的密钥"' >> ~/.zshrc
source ~/.zshrc
```

如果你在中国大陆，也可以通过Amazon Bedrock或Google Vertex AI接入，具体方法请参考[Claude Code国内使用指南](/claude-code-guonei-shiyong-china-usage-guide/)。

## 第一次使用Claude Code

### 启动Claude Code

进入你的项目目录，然后启动Claude Code：

```bash
cd /你的项目路径
claude
```

首次启动时，Claude Code会检测API密钥配置，连接到Anthropic服务器，并显示交互界面。你会看到一个类似聊天窗口的命令行界面，可以直接用自然语言输入任务。

### 第一个任务

尝试输入以下内容来熟悉Claude Code：

```
帮我了解一下这个项目的结构，列出主要的目录和文件
```

Claude Code会自动扫描你的项目目录，分析文件结构，并给出项目概览。这是了解新项目的绝佳起点。

### 基本对话模式

Claude Code支持多轮对话。你可以像和同事交流一样，逐步深入：

```
用户：这个项目的入口文件在哪里？
Claude Code：[分析并回答]

用户：帮我看看入口文件中的main函数做了什么
Claude Code：[读取文件并解释]

用户：帮我在main函数中添加一个日志记录
Claude Code：[修改文件并展示变更]
```

每次Claude Code要修改文件或执行命令时，它会先告诉你它打算做什么，等你确认后再执行。

## 常用命令详解

Claude Code提供了一组斜杠命令来控制行为和优化使用体验。

### /init — 初始化项目配置

```bash
/init
```

这个命令会在项目根目录创建CLAUDE.md配置文件。CLAUDE.md是Claude Code了解你项目的关键，包含项目描述、技术栈信息、编码规范等。

运行 `/init` 后，Claude Code会：

1. 分析项目结构和技术栈
2. 读取现有的配置文件（package.json、tsconfig.json等）
3. 生成一份初始的CLAUDE.md文件
4. 你可以根据需要编辑和完善这个文件

关于CLAUDE.md的详细配置方法，请参考[CLAUDE.md文件完整指南](/claude-md-file-complete-guide-what-it-does/)。

### /compact — 压缩对话历史

```bash
/compact
```

随着对话进行，上下文会越来越长，消耗更多Token。`/compact` 会压缩之前的对话内容，保留关键信息，减少后续请求的Token消耗。

**何时使用**：
- 对话进行了10轮以上
- 感觉响应速度变慢
- Claude Code开始"忘记"之前的上下文

**最佳实践**：每完成一个独立任务后使用 `/compact`，然后开始下一个任务。

### /cost — 查看费用

```bash
/cost
```

显示当前会话的Token消耗和费用统计。对于使用API密钥的用户来说，这个命令很重要，可以帮助你监控开支。关于费用优化的详细建议，请参考[Claude Code价格指南](/claude-code-jiage-pricing-guide/)。

### /help — 获取帮助

```bash
/help
```

列出所有可用的斜杠命令和使用说明。当你忘记某个命令的用法时，这是最快的参考方式。

### /model — 切换模型

```bash
/model sonnet    # 切换到Sonnet模型（性价比高）
/model opus      # 切换到Opus模型（能力最强）
```

不同任务适合不同模型：
- **Sonnet**：日常编码、代码审查、简单重构（推荐默认使用）
- **Opus**：复杂架构设计、大型重构、高难度调试

### /clear — 清除对话

```bash
/clear
```

完全清除当前对话历史，重新开始。与 `/compact` 不同，`/clear` 会删除所有上下文。

### 其他实用命令

| 命令 | 功能 | 使用场景 |
|-----|------|---------|
| `/bug` | 报告Bug | 发现Claude Code的问题时使用 |
| `/config` | 打开配置 | 修改Claude Code的行为设置 |
| `/logout` | 退出登录 | 切换API密钥或账户 |
| `/status` | 查看状态 | 检查连接和配置状态 |

关于更多快捷键和命令的详细说明，请参考[Claude Code快捷键完整指南](/claude-shortcuts-complete-guide/)。

## CLAUDE.md配置文件

CLAUDE.md是Claude Code的核心配置机制。它是一个放在项目根目录的Markdown文件，告诉Claude Code你的项目信息和工作规范。

### 基本结构

```markdown
# 项目名称

## 项目描述
这是一个基于React和TypeScript的前端项目...

## 技术栈
- React 18
- TypeScript 5
- Vite
- Tailwind CSS

## 编码规范
- 使用函数组件和Hooks
- 组件文件使用PascalCase命名
- 工具函数使用camelCase命名
- 所有函数必须有TypeScript类型标注

## 项目结构
- src/components/ — React组件
- src/hooks/ — 自定义Hooks
- src/utils/ — 工具函数
- src/types/ — TypeScript类型定义

## 常用命令
- npm run dev — 启动开发服务器
- npm run build — 构建生产版本
- npm run test — 运行测试
- npm run lint — 代码检查
```

### CLAUDE.md的层级

Claude Code支持多层级的配置文件：

1. **项目级**：`/项目根目录/CLAUDE.md` — 适用于整个项目
2. **目录级**：`/项目根目录/src/CLAUDE.md` — 仅适用于src目录
3. **用户级**：`~/.claude/CLAUDE.md` — 适用于你的所有项目

这种层级设计允许你为不同的子目录设置不同的规范。例如，前端目录和后端目录可以有不同的编码规范。

### 实用配置示例

**限制Claude Code的行为**：

```markdown
## 规则
- 不要修改 package.json 中的依赖版本
- 修改API接口文件前必须先运行现有测试
- 新增函数必须附带单元测试
- 不要删除代码注释
```

**提供项目上下文**：

```markdown
## 架构说明
本项目使用微服务架构：
- user-service: 用户认证和管理
- order-service: 订单处理
- notification-service: 消息通知

服务间通过REST API通信，消息队列使用RabbitMQ。
```

更多CLAUDE.md的高级用法和模板，请参考[Claude Code最佳CLAUDE.md企业模板](/best-claude-md-templates-enterprise-2026/)。

## 文件操作

文件操作是Claude Code最常用的功能之一。

### 读取文件

```
请帮我看看 src/App.tsx 的内容
```

Claude Code会读取指定文件并展示内容。你可以接着问关于文件内容的问题。

### 编辑文件

```
在 src/utils/format.ts 中添加一个日期格式化函数
```

Claude Code会：
1. 读取目标文件
2. 分析现有代码结构
3. 在合适的位置添加新函数
4. 展示修改前后的差异
5. 等待你确认后保存

### 创建新文件

```
创建一个新的React组件 UserProfile，放在 src/components/UserProfile.tsx
```

Claude Code会根据项目的技术栈和编码规范来生成新文件。

### 批量修改

```
把项目中所有使用console.log的地方替换成logger.debug
```

Claude Code会搜索整个项目，找到所有匹配的位置，然后逐个或批量替换。

### 使用.claudeignore

类似于.gitignore，你可以创建.claudeignore文件来排除Claude Code不需要读取的目录：

```
# .claudeignore
node_modules/
dist/
build/
.next/
coverage/
*.min.js
```

这样做的好处：
- 减少自动上下文的Token消耗
- 加快文件搜索速度
- 避免Claude Code读取不相关的文件

## 使用MCP服务器

MCP（Model Context Protocol）是Claude Code的扩展机制，允许你连接外部工具和数据源。

### 什么是MCP

MCP服务器就像是Claude Code的"插件"，提供额外的能力。例如：

- 连接数据库查询数据
- 访问API获取实时信息
- 操作Kubernetes集群
- 管理AWS资源

### 配置MCP服务器

MCP服务器通过配置文件或命令行参数添加。常见的配置方式：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "你的GitHub Token"
      }
    }
  }
}
```

### 常用MCP服务器

| MCP服务器 | 功能 | 适用场景 |
|-----------|------|---------|
| filesystem | 文件系统操作 | 管理项目外的文件 |
| github | GitHub集成 | PR管理、Issue跟踪 |
| postgres | PostgreSQL查询 | 数据库调试和分析 |
| brave-search | 网络搜索 | 查找文档和解决方案 |

更多MCP服务器的配置和使用方法，请参考[Claude Code MCP配置指南](/claude-code-mcp-configuration-guide/)和[最佳MCP集成方案](/best-claude-code-mcp-integrations-2026/)。

## 实际开发场景示例

### 场景一：调试一个Bug

```
用户：运行 npm test 后，UserService.test.ts 的第42行测试失败了，
      错误信息是 "Expected 200 but received 401"

Claude Code：让我查看测试文件和对应的服务代码...
      [读取测试文件]
      [读取UserService源码]
      [分析错误原因]

      问题找到了：UserService在调用API时没有设置认证头。
      以下是修复方案：
      [展示代码修改]

用户：看起来正确，请应用修改

Claude Code：[修改文件]
      [运行测试验证]
      测试通过了。
```

### 场景二：添加新功能

```
用户：我需要为用户列表添加分页功能。目前的UserList组件
      一次加载所有用户，改成每页显示20条，支持翻页。

Claude Code：我来分析当前的实现并添加分页功能...
      [读取UserList组件]
      [读取相关API接口]
      [制定修改方案]

      我需要修改以下文件：
      1. src/api/users.ts — 添加分页参数
      2. src/components/UserList.tsx — 添加分页UI和状态管理
      3. src/hooks/useUsers.ts — 修改数据获取逻辑

      要我开始吗？
```

### 场景三：代码审查

```
用户：请审查 src/utils/auth.ts 的安全性

Claude Code：[读取文件]
      我发现以下安全问题：

      1. 第23行：JWT密钥硬编码在源码中
         建议：移到环境变量
      2. 第45行：Token过期时间设置为30天
         建议：缩短到24小时，使用refresh token机制
      3. 第67行：密码比较使用了 === 运算符
         建议：使用timing-safe比较防止时序攻击
```

### 场景四：Git操作

```
用户：帮我提交当前的修改，commit message写清楚改了什么

Claude Code：[运行 git status 查看修改]
      当前修改了3个文件：
      - src/api/users.ts（添加分页参数）
      - src/components/UserList.tsx（分页UI）
      - src/hooks/useUsers.ts（分页逻辑）

      建议的commit message：
      "feat: add pagination to user list (20 items per page)"

      要我执行提交吗？
```

## 中国开发者建议

作为中国开发者使用Claude Code，以下是一些特别的建议。

### 网络优化

在中国大陆使用Claude Code，网络连接是最大的挑战。推荐以下方案：

1. **个人开发者**：配置终端代理（推荐日本或新加坡节点）
2. **企业团队**：使用Amazon Bedrock或Google Vertex AI

详细的网络配置方案请参考[Claude Code国内使用指南](/claude-code-guonei-shiyong-china-usage-guide/)。

### 中文提示词

Claude Code完全支持中文输入和输出。你可以用中文描述需求：

```
帮我把这个函数的注释改成中文
```

但需要注意：
- 代码中的变量名和函数名建议使用英文
- Git commit message建议使用英文（方便国际化团队协作）
- CLAUDE.md中的规范说明可以使用中文

### 费用控制

API按量计费时，中文内容的Token消耗比英文稍高（1个中文字约1-2个Token，而1个英文单词约1个Token）。建议：

- 日常编码使用Sonnet模型（性价比最高）
- 使用 `/compact` 定期压缩对话
- 设置费用上限防止意外超支
- 利用Prompt Caching在同一会话中持续工作

关于费用的详细分析，请参考[Claude Code价格指南](/claude-code-jiage-pricing-guide/)。

### 代码示例中的注释

在CLAUDE.md中指定注释语言：

```markdown
## 编码规范
- 代码注释使用中文
- 变量和函数名使用英文
- README和文档使用中文
```

这样Claude Code会按照你的偏好生成中文注释。

## 进阶技巧

### 多文件重构

Claude Code擅长跨文件重构。你可以一次性描述整个重构任务：

```
把项目中所有使用Redux的状态管理重构为Zustand。
需要修改store定义、组件中的useSelector/useDispatch调用，
以及相关的类型定义。
```

Claude Code会系统地搜索所有相关文件，制定修改计划，然后逐个修改。

### 使用Hooks自动化

Claude Code支持Hooks机制，可以在特定事件发生时自动执行操作。例如：

- 文件保存后自动运行lint
- 修改代码后自动运行相关测试
- 提交前检查代码规范

关于Hooks的详细配置，请参考[Claude Code Hooks代码质量指南](/best-claude-code-hooks-code-quality-2026/)。

### 后台Agent任务

如果你使用Max计划，可以让Claude Code在后台运行长时间任务：

```
在后台运行：分析整个项目的依赖关系，找出所有未使用的依赖
```

这样你可以继续其他工作，Claude Code在后台完成分析后会通知你。

### 自定义Skills

Claude Code支持自定义Skills来封装重复性的工作流。Skills是预定义的提示词模板，可以通过斜杠命令快速调用。

关于Skills的创建和使用，请参考[Claude Code最佳Skills排行](/best-claude-code-skills-ranked-2026/)。

## 常见问题排查

### 连接问题

如果遇到连接超时或断开：

1. 检查API密钥是否正确设置
2. 验证网络连通性：`curl -I https://api.anthropic.com`
3. 中国用户检查代理配置

关于exit code 1等错误的详细排查，请参考[Claude Code进程退出码修复指南](/claude-code-process-exited-code-1-fix/)。

### 性能优化

如果Claude Code响应缓慢：

1. 使用 `/compact` 压缩对话历史
2. 检查.claudeignore是否排除了大目录
3. 考虑切换到Sonnet模型（比Opus快）
4. 确保网络连接稳定

### 文件权限问题

如果Claude Code无法读取或写入文件：

1. 检查文件权限：`ls -la 文件路径`
2. 确认当前用户有读写权限
3. 避免在受保护的系统目录中运行

---

*这些模板来自 [Claude Code Playbook](https://zovo.one/pricing) — 包含200个生产就绪模板和团队配置指南。*

## 总结

Claude Code是一个功能强大的AI编程助手，掌握它的关键在于：

1. **正确配置环境**：Node.js 18+、API密钥、网络连接
2. **善用CLAUDE.md**：让Claude Code了解你的项目和规范
3. **掌握常用命令**：`/init`、`/compact`、`/cost`、`/model`
4. **合理控制成本**：选择合适的模型、使用缓存、压缩上下文
5. **扩展能力**：通过MCP服务器连接外部工具

随着使用时间的增长，你会发现Claude Code在代码审查、调试和重构等复杂任务上的效率远超手动操作。

如果你还没有安装，请先阅读[Claude Code安装教程](/claude-code-anzhuang-installation-guide/)。如果你想了解更多费用信息，请参考[Claude Code价格指南](/claude-code-jiage-pricing-guide/)。已经在使用的开发者，可以查看[Claude Code生产力技巧](/best-claude-code-productivity-hacks-2026/)来进一步提升效率。

## 常见问题

### Claude Code和Claude Desktop有什么区别？

Claude Code是命令行工具，运行在终端中，专注于编程任务，可以直接读写文件和执行Shell命令。Claude Desktop是图形界面应用程序，适合通用对话。两者独立安装，使用不同的界面，但都基于Claude AI模型。对于开发者来说，Claude Code更适合编程工作流。

### Claude Code支持哪些编程语言？

Claude Code本身是语言无关的，可以处理任何编程语言的代码。它对Python、JavaScript、TypeScript、Go、Rust、Java、C++等主流语言有很好的支持。代码补全、调试建议和重构功能在所有语言中都可用。

### 如何让Claude Code记住我的项目规范？

使用CLAUDE.md文件。在项目根目录创建CLAUDE.md，写入你的项目描述、技术栈、编码规范和常用命令。Claude Code每次启动时会自动读取这个文件，按照你的规范来工作。你也可以运行 /init 命令让Claude Code自动生成初始配置。

### Claude Code会修改我的代码吗？

Claude Code在修改代码之前会先展示修改方案，等待你确认后才会实际写入文件。你可以查看修改前后的差异，然后决定是否接受。如果你使用了Git，所有修改都可以通过git回退。

### 如何限制Claude Code可以访问的文件？

创建.claudeignore文件（类似.gitignore），列出不想让Claude Code访问的目录和文件。例如排除node_modules、dist、.env等。这不仅保护隐私，还能减少Token消耗。

### Claude Code的对话有长度限制吗？

Claude Code的单次对话有上下文长度限制（与Claude模型的上下文窗口一致）。当对话变长时，使用 /compact 命令压缩历史记录。如果需要完全重新开始，使用 /clear 命令清除所有上下文。

### Claude Code可以同时处理多个项目吗？

可以。在不同的终端窗口中启动Claude Code，分别进入不同的项目目录即可。每个Claude Code实例独立运行，互不影响。但注意多个实例会各自消耗Token额度。

### 如何在VSCode中使用Claude Code？

Claude Code可以在VSCode的内置终端中运行。打开VSCode终端，输入claude即可启动。此外，Claude Code也有VSCode扩展，可以更好地集成到IDE工作流中。

### Claude Code可以运行测试吗？

可以。Claude Code可以执行Shell命令，包括运行测试框架。你可以说"运行所有测试"或"运行UserService的测试"，Claude Code会执行相应的测试命令并分析结果。

### 在中国大陆使用Claude Code需要翻墙吗？

使用Anthropic直接API需要代理或VPN。但你也可以通过Amazon Bedrock或Google Vertex AI接入，某些情况下可能有更好的网络体验。具体的网络配置和代理方案请参考我们的国内使用指南。

### Claude Code会上传我的代码到服务器吗？

Claude Code会将你的提示词和相关代码上下文发送到Anthropic的API服务器进行处理。Anthropic声明不会使用API数据来训练模型。如果有数据安全顾虑，企业用户可以使用Bedrock或Vertex，它们提供更严格的数据处理协议。

### 如何从Claude Code中获得中文回复？

直接用中文提问即可。Claude Code会自动检测你的输入语言并用对应的语言回复。你也可以在CLAUDE.md中明确指定"所有回复使用中文"来确保一致性。

{% raw %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Claude Code和Claude Desktop有什么区别？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code是命令行工具，运行在终端中，专注于编程任务。Claude Desktop是图形界面应用程序，适合通用对话。两者独立安装，使用不同的界面，但都基于Claude AI模型。"}},
    {"@type": "Question", "name": "Claude Code支持哪些编程语言？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code本身是语言无关的，可以处理任何编程语言的代码。它对Python、JavaScript、TypeScript、Go、Rust、Java、C++等主流语言有很好的支持。"}},
    {"@type": "Question", "name": "如何让Claude Code记住我的项目规范？", "acceptedAnswer": {"@type": "Answer", "text": "使用CLAUDE.md文件。在项目根目录创建CLAUDE.md，写入项目描述、技术栈、编码规范和常用命令。Claude Code每次启动时会自动读取这个文件。"}},
    {"@type": "Question", "name": "Claude Code会修改我的代码吗？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code在修改代码之前会先展示修改方案，等待你确认后才会实际写入文件。你可以查看修改前后的差异，然后决定是否接受。"}},
    {"@type": "Question", "name": "如何限制Claude Code可以访问的文件？", "acceptedAnswer": {"@type": "Answer", "text": "创建.claudeignore文件，列出不想让Claude Code访问的目录和文件。例如排除node_modules、dist、.env等。"}},
    {"@type": "Question", "name": "Claude Code的对话有长度限制吗？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code的单次对话有上下文长度限制。当对话变长时，使用 /compact 命令压缩历史记录。如果需要完全重新开始，使用 /clear 命令清除所有上下文。"}},
    {"@type": "Question", "name": "Claude Code可以同时处理多个项目吗？", "acceptedAnswer": {"@type": "Answer", "text": "可以。在不同的终端窗口中启动Claude Code，分别进入不同的项目目录即可。每个实例独立运行，互不影响。但注意多个实例会各自消耗Token额度。"}},
    {"@type": "Question", "name": "如何在VSCode中使用Claude Code？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code可以在VSCode的内置终端中运行。打开VSCode终端，输入claude即可启动。此外也有VSCode扩展可以更好地集成到IDE工作流中。"}},
    {"@type": "Question", "name": "Claude Code可以运行测试吗？", "acceptedAnswer": {"@type": "Answer", "text": "可以。Claude Code可以执行Shell命令，包括运行测试框架。你可以说'运行所有测试'，Claude Code会执行相应的测试命令并分析结果。"}},
    {"@type": "Question", "name": "在中国大陆使用Claude Code需要翻墙吗？", "acceptedAnswer": {"@type": "Answer", "text": "使用Anthropic直接API需要代理或VPN。但也可以通过Amazon Bedrock或Google Vertex AI接入，某些情况下可能有更好的网络体验。"}},
    {"@type": "Question", "name": "Claude Code会上传我的代码到服务器吗？", "acceptedAnswer": {"@type": "Answer", "text": "Claude Code会将提示词和相关代码上下文发送到Anthropic的API服务器进行处理。Anthropic声明不会使用API数据来训练模型。企业用户可以使用Bedrock或Vertex获得更严格的数据处理协议。"}},
    {"@type": "Question", "name": "如何从Claude Code中获得中文回复？", "acceptedAnswer": {"@type": "Answer", "text": "直接用中文提问即可。Claude Code会自动检测输入语言并用对应的语言回复。也可以在CLAUDE.md中明确指定所有回复使用中文来确保一致性。"}}
  ]
}
</script>



**Quick reference →** Search all commands in our [Command Reference](/commands/).

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code拼车指南：合租与共享方案 (2026)](/claude-code-pinche-group-sharing/)

{% endraw %}