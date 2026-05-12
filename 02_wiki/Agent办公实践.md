---
title: Agent 办公实践
tags: [工具, AI Coding, 飞书, Claude Code, remote, 办公自动化]
created: 2026-05-12
source: 01_sources/_archived/remote-claude，用手机远程鞭策ClaudeCode干活.md, 01_sources/_archived/分享5个Claude Code + 飞书的超实用Agent办公玩法。.md
---

# Agent 办公实践

## remote-claude：手机远程操控 Claude Code

**核心痛点**：使用 Claude Code 时人不能离开电脑，AI 随时需要确认信息。

**解决方案**：通过飞书接收 Claude 会话输出 + 远程发送指令。

- 仓库：https://github.com/yyzybb537/remote_claude
- 安装：`npm install remote-claude` 或源码安装
- 配置飞书机器人：`remote-claude lark init`
- 启动：`cla`（启动飞书客户端 + Claude）
- 也支持 Codex

## 飞书 CLI + Agent 办公场景

飞书 CLI 开源，覆盖 15 个业务域、114+ 个能力，GitHub star 近万。

### 5 个典型场景

1. **会议知识库**：跨场次自动抓取妙记，沉淀为可检索的结构化知识库
2. **工作复盘**：分 8 路并行抓取消息/会议/妙记/日程/任务/邮件/文档/OKR，生成季度报告
3. **对账自动化**：机器人拉取多维表格数据 → 群里@博主确认 → 按反馈自动分流给对应同事
4. **可协同画板**：一句话生成飞书原生画板（架构图/流程图/PPT），全员可编辑
5. **自动报销审批**：Agent 搜邮箱找发票 → 匹配报销 SOP → 提交申请 → 审批人确认

### 核心洞察

> 协同，协同，还是协同。Agent 操控飞书，形成多方位的提效和协同。

Agent 的办公协同趋向两种形式：
- **本地自己玩**
- **在公司里跟同事强协同**（甚至机器人@机器人，AI 之间自己协同）

## 相关页面

- [[Ralph_Loop]] — remote-claude 解决了 Ralph Loop 中的"人不能离开电脑"问题
- [[Warp_Terminal]] — 另一种终端 Agent 协同方式
- [[Agent_Skill设计模式]] — 飞书办公场景可封装为 Skill
