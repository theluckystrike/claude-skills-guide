---

layout: default
title: "Claude Code for Rootly Incident Workflow Tutorial"
description: "Learn how to integrate Claude Code with Rootly incident management to automate runbooks, streamline response workflows, and reduce MTTR. Practical."
date: 2026-03-15
author: "Claude Skills Guide"
categories: [tutorials]
tags: [claude-code, rootly, incident-management, devops, automation, claude-skills]
permalink: /claude-code-for-rootly-incident-workflow-tutorial/
reviewed: true
score: 7
---


{% raw %}
# Claude Code for Rootly Incident Workflow Tutorial

When production incidents strike, every minute counts. Teams need快速诊断、自动化的故障排除流程，以及高效的协调工具来缩短平均修复时间 (MTTR)。本教程将向您展示如何将 Claude Code 与 Rootly 集成，构建一个智能 incident response 工作流。

Rootly 是一个现代 incident management 平台，提供自动化 runbook、SLO 追踪和 post-mortem 功能。结合 Claude Code 的代码理解和任务自动化能力，您可以创建强大的 incident response 工作流。

## 前提条件

在开始之前，确保您具备以下条件：

- **Rootly 账户**：拥有 Rootly 组织的访问权限
- **Rootly API 密钥**：在 Rootly 设置中生成 API 凭证
- **Claude Code 已安装**：本地开发环境配置完成
- **Node.js 16+ 或 Python 3.8+**：用于运行集成脚本

## 设置 Rootly 与 Claude Code 的集成

### 第一步：获取 Rootly API 凭证

登录 Rootly 后，导航至 **Settings → API** 页面。创建新的 API 令牌：

```bash
# 存储为环境变量（不要提交到版本控制）
export ROOTLY_API_KEY="your_api_key_here"
export ROOTLY_ORGANIZATION="your_org_slug"
```

### 第二步：创建 Rootly MCP Server 配置

Claude Code 通过 MCP (Model Context Protocol) 与外部服务通信。以下是配置 Rootly MCP server 的方法：

```json
{
  "mcpServers": {
    "rootly": {
      "command": "npx",
      "args": ["-y", "@rootly/mcp-server"],
      "env": {
        "ROOTLY_API_KEY": "{{env.ROOTLY_API_KEY}}",
        "ROOTLY_ORGANIZATION": "{{env.ROOTLY_ORGANIZATION}}"
      }
    }
  }
}
```

将此配置添加到您的 Claude Code 配置文件 (`claude_settings.json`) 中。

### 第三步：验证连接

确认 MCP server 已正确配置：

```bash
claude # 启动 Claude Code 并验证 MCP server 连接
```

您应该能在输出中看到 rootly server。

## 核心 Incident Workflow 场景

### 场景一：自动创建 Incident

当监控警报触发时，自动在 Rootly 中创建 incident：

```typescript
// create-incident.ts
import { Rootly } from '@rootly/node';

const rootly = new Rootly({
  apiKey: process.env.ROOTLY_API_KEY!,
  organization: process.env.ROOTLY_ORGANIZATION!
});

interface IncidentPayload {
  title: string;
  severity: 'critical' | 'high' | 'medium' | 'low';
  description: string;
  commander?: string;
}

export async function createIncident(payload: IncidentPayload) {
  const incident = await rootly.incidents.create({
    data: {
      type: 'incident',
      attributes: {
        title: payload.title,
        severity: payload.severity,
        description: payload.description,
        status: 'triggered'
      }
    }
  });

  // 自动分配 incident commander
  if (payload.commander) {
    await rootly.incident_roles.assign(incident.data.id, {
      role: 'commander',
      email: payload.commander
    });
  }

  return incident;
}

// 使用示例
await createIncident({
  title: 'API 500 Error Rate Spike',
  severity: 'critical',
  description: 'Error rate exceeded 5% threshold in the last 5 minutes',
  commander: 'on-call@company.com'
});
```

### 场景二：自动执行 Runbook

结合 Claude Code 的代码理解能力，您可以自动执行诊断步骤：

```python
# runbook_executor.py
import subprocess
import json
from typing import List, Dict, Any

class RunbookExecutor:
    def __init__(self, rootly_api_key: str, org: str):
        self.rootly_api_key = rootly_api_key
        self.org = org
        self.incident_id = None

    def start_runbook(self, incident_id: str, runbook_id: str):
        """启动 Rootly runbook 并执行自动化步骤"""
        self.incident_id = incident_id
        
        # 从 Rootly 获取 runbook 详情
        runbook = self._get_runbook(runbook_id)
        steps = runbook['attributes']['steps']
        
        results = []
        for step in steps:
            result = self._execute_step(step)
            results.append(result)
            
            # 将结果同步回 Rootly
            self._update_incident_status(step, result)
        
        return results

    def _execute_step(self, step: Dict) -> Dict[str, Any]:
        """执行单个 runbook 步骤"""
        step_type = step['type']
        
        if step_type == 'command':
            # 执行 shell 命令
            cmd = step['command']
            output = subprocess.run(
                cmd, shell=True, capture_output=True, text=True
            )
            return {
                'step': step['title'],
                'status': 'success' if output.returncode == 0 else 'failed',
                'output': output.stdout,
                'error': output.stderr
            }
        
        elif step_type == 'http_request':
            # 执行 HTTP 检查
            import requests
            response = requests.request(
                method=step['method'],
                url=step['url'],
                headers=step.get('headers', {}),
                timeout=10
            )
            return {
                'step': step['title'],
                'status': 'success' if response.ok else 'failed',
                'output': response.text
            }
        
        return {'step': step['title'], 'status': 'skipped'}

    def _get_runbook(self, runbook_id: str) -> Dict:
        import requests
        response = requests.get(
            f"https://api.rootly.com/runbooks/{runbook_id}",
            headers=self._auth_headers()
        )
        return response.json()

    def _auth_headers(self) -> Dict:
        return {
            'Authorization': f'Bearer {self.rootly_api_key}',
            'Content-Type': 'application/vnd.api+json'
        }

# 使用 Claude Code 执行复杂诊断
CLAUDE_PROMPT = """
分析这个 incident：API 延迟超过 2 秒
请执行以下诊断步骤：
1. 检查当前 API 响应时间
2. 查看最近部署的代码变更
3. 检查数据库连接池状态
4. 分析错误日志中的模式

将诊断结果格式化输出，并建议下一步行动。
"""

def run_ai_diagnosis(prompt: str) -> str:
    """使用 Claude Code 进行 AI 辅助诊断"""
    # 实际使用时调用 Claude API
    pass
```

### 场景三：Post-Mortem 自动生成

Incident 解决后，自动生成 post-mortem 文档：

```typescript
// auto-postmortem.ts
interface IncidentTimeline {
  timestamp: Date;
  action: string;
  actor: string;
  details: string;
}

export async function generatePostmortem(incidentId: string): Promise<string> {
  // 1. 获取 incident 数据
  const incident = await rootly.incidents.get(incidentId);
  const timeline = await rootly.incidents.timeline(incidentId);
  
  // 2. 获取相关指标
  const metrics = await fetchIncidentMetrics(incidentId);
  
  // 3. 使用 Claude Code 生成 post-mortem
  const prompt = `
请基于以下数据生成一份 incident post-mortem：

## Incident 概述
- 标题: ${incident.data.attributes.title}
- 严重程度: ${incident.data.attributes.severity}
- 持续时间: ${calculateDuration(incident)}
- 影响范围: ${incident.data.attributes.impact}

## 时间线
${formatTimeline(timeline)}

## 关键指标
${JSON.stringify(metrics, null, 2)}

请按照以下格式生成：
1. 摘要 (Summary)
2. 根本原因 (Root Cause)
3. 触发因素 (Trigger)
4. 影响范围 (Impact)
5. 响应时间线 (Timeline)
6. 缓解措施 (Resolution)
7. 预防措施 (Prevention)
  `;
  
  // 调用 Claude API 生成内容
  const postmortem = await callClaudeAPI(prompt);
  
  // 4. 保存到 Rootly
  await rootly.incident_documents.create(incidentId, {
    title: 'Post-Mortem',
    content: postmortem,
    document_type: 'postmortem'
  });
  
  return postmortem;
}
```

## 高级工作流：AI-Driven Incident Response

### 完整自动化流程

```yaml
# .claude/workflows/incident-response.md
# Claude Code 技能：智能 Incident Response

## 触发条件
当检测到以下情况时自动激活：
- PagerDuty 告警
- Datadog 异常检测
- 自定义监控阈值

## 工作流步骤

### 1. 收集上下文
- 获取 incident 详情
- 拉取相关指标和日志
- 检查最近的代码部署

### 2. 初步诊断
使用 Claude Code 分析：
```
分析以下错误日志，识别模式：
{{error_logs}}

检查以下指标：
{{metrics_data}}
```

### 3. 建议行动
基于诊断结果，提供：
- 可能的原因
- 推荐的操作步骤
- 需要升级的情况

### 4. 执行自动化
如果 runbook 可用：
- 自动执行诊断步骤
- 记录每步结果
- 实时更新 incident 状态

### 5. 升级路径
当自动响应失败时：
- 自动通知 on-call 人员
- 创建 incident channel（如 Slack）
- 准备 escalation 信息

## 最佳实践

### 1. 分阶段执行
不要让 AI 完全自动化高风险操作。关键步骤保持人工审批：

```typescript
const APPROVED_ACTIONS = [
  'read_logs',
  'check_metrics',
  'run_diagnostics',
  'update_status'
];

const REQUIRES_APPROVAL = [
  'rollback_deployment',
  'scale_infrastructure',
  'clear_cache',
  'execute_rollback'
];

async function executeAction(action: string, params: any) {
  if (REQUIRES_APPROVAL.includes(action)) {
    const approval = await requestHumanApproval(action, params);
    if (!approval.granted) return;
  }
  await performAction(action, params);
}
```

### 2. 持续学习
保存所有 incident 响应记录，用于训练和改进：

- 记录诊断成功率
- 跟踪 MTTR 改进
- 识别常见模式

### 3. 安全第一
- 限制 AI 可以执行的危险操作
- 审计所有自动执行的操作
- 保持完整的操作日志

## 总结

将 Claude Code 与 Rootly 集成可以显著提升 incident response 效率：

1. **快速诊断**：AI 辅助分析日志和指标
2. **自动化执行**：减少人工重复劳动
3. **标准化流程**：确保一致的事件响应
4. **持续改进**：基于历史数据优化工作流

开始小规模试点，选择低风险场景，逐步扩展到关键业务系统。

## Practical Integration Patterns

### Routing Alerts from Multiple Sources

The most effective Rootly and Claude Code setups pipe alerts from PagerDuty, Datadog, and custom webhooks into one standardized Rootly incident. A routing function maps each source into a consistent incident payload:

```typescript
// alert-router.ts
interface AlertPayload {
  source: string;
  severity: 'critical' | 'high' | 'medium' | 'low';
  title: string;
  description: string;
}

async function routeAlertToRootly(alert: AlertPayload) {
  const incident = await createIncident({
    title: `[${alert.source.toUpperCase()}] ${alert.title}`,
    severity: alert.severity,
    description: alert.description
  });

  // Tag incident with originating source for retrospectives
  await rootly.incident_attributes.set(incident.data.id, {
    alert_source: alert.source,
    auto_created: true
  });

  return incident;
}
```

This centralizes incident creation so your team works from one view regardless of which monitoring tool fired.

### Auto-Creating Slack Channels

Automatically create a dedicated Slack channel when an incident is declared:

```typescript
import { WebClient } from '@slack/web-api';
const slack = new WebClient(process.env.SLACK_BOT_TOKEN);

async function createIncidentChannel(incident: any) {
  const channelName = `inc-${incident.data.id}`.toLowerCase();
  const channel = await slack.conversations.create({ name: channelName });

  await slack.chat.postMessage({
    channel: channel.channel!.id!,
    text: `Incident: ${incident.data.attributes.title} | Severity: ${incident.data.attributes.severity}`
  });

  await rootly.incident_attributes.set(incident.data.id, {
    slack_channel_id: channel.channel!.id
  });

  return channel;
}
```

## Common Pitfalls to Avoid

**Over-automating too quickly**: Start with read-only diagnosis — log analysis, metric queries, runbook retrieval. Only expand to write operations after the read-only workflow has proven reliable over several real incidents. Moving too fast to automated remediation before the analysis is accurate leads to automation making things worse during an outage.

**Missing human approval gates**: Even well-tested automation can execute destructive actions at the wrong moment. Keep the `REQUIRES_APPROVAL` list from the workflow example, and expand it conservatively. Rollbacks, cache clears, and infrastructure scaling should always require an explicit human confirmation before execution.

**Ignoring rate limits**: The Rootly API enforces rate limits per organization. During a major outage, dozens of alerts can fire simultaneously. Implement exponential backoff and use Rootly's `unique_identifier` field to deduplicate incidents. Pass a hash of the alert title and affected service name so Rootly links subsequent alerts to the existing incident rather than creating duplicates.

**Severity case sensitivity**: In the Rootly API, severity values must be lowercase (`critical`, `high`, `medium`, `low`). Passing `CRITICAL` or `Critical` returns a 422 validation error that can silently drop incident creation in automated pipelines.

## Measuring Impact Over Time

Track these metrics to quantify improvement after deployment:

- **MTTA (Mean Time to Acknowledge)**: Should decrease as Claude Code auto-assigns incidents and creates channels instantly. Establish a baseline before deployment.
- **MTTR (Mean Time to Resolve)**: Improves when automated runbook execution handles the first 15-20 minutes of triage. Compare incidents where runbooks fired versus those that required full manual response.
- **False positive remediation rate**: How often automated responses ran unnecessarily. Use this signal to tighten alert thresholds and improve runbook decision logic over time.
- **Post-mortem completion rate**: With auto-generation, this typically rises from 60-70% to near 100% because the skeleton is pre-filled before the incident closes.

Review metrics weekly for the first month after deployment. If MTTA improves but MTTR does not, the bottleneck has shifted to the resolution phase — that becomes your next automation target.

## Troubleshooting Common Issues

**MCP server fails to connect on startup**: Verify `ROOTLY_API_KEY` is exported in your shell before launching Claude Code. The MCP server reads credentials at startup, not lazily per request. Restart Claude Code after setting the variable.

**Runbook steps time out**: The default HTTP timeout in the Python executor is 10 seconds. For steps that call slow internal services, increase it to 30-60 seconds and add idempotency checks so retries do not double-execute destructive steps.

**Post-mortem call returns 409**: The `incident_documents.create` endpoint requires the incident to be in `resolved` or `monitoring` status. Calling it while the incident is still `triggered` returns a 409 conflict. Add a status check before generating the post-mortem, or subscribe to the Rootly `incident.resolved` webhook event to trigger generation automatically at the right time.

{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
