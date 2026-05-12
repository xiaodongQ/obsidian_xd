---
title: Ralph Loop
tags: [概念, AI Coding, Ralph Loop, Claude Code, 自主循环, Agent]
created: 2026-05-09
source: 01_sources/_archived/Ralph_Loop_调研.md
---

# Ralph Loop

## 概述

**Ralph Loop** 是 2025 年底在 AI Coding 社区疯传的自主循环开发技术，以《辛普森一家》角色命名。其核心是将 AI 编码 Agent 包裹在 Bash while 循环中反复执行，直到满足完成条件。

> "That's the beauty of Ralph - the technique is deterministically bad in an undeterministic world."
> — Geoffrey Huntley

名字来源于《辛普森一家》角色 Ralph Wiggum——全剧最"单纯"的人，标志性台词"I'm helping!"揭示了这项技术的精髓：**天真且不懈的坚持（Naive and relentless persistence）**。

> **重要区分**：Ralph 是方法论，不是工具。就像"敏捷开发"是方法论而不是某个软件。

## 核心原理

**传统问题**：LLM 上下文窗口有上限，长时间任务中上下文污染导致 AI "失忆"，产出质量下降。

**Ralph 解决**：每个迭代是**全新的 AI 实例**，状态存储在文件和 Git 中，而非 LLM 记忆窗口。

```bash
while ! grep -q "DONE" state.md; do
  claude --print --prompt "执行下一个任务..."
done
```

| 设计原则 | 说明 |
|----------|------|
| 小任务 | 每个迭代只做一个，降低失败成本 |
| 状态外化 | 所有状态写入文件，不依赖 LLM 记忆 |
| 上下文刷新 | 每个迭代重新读文件，保持"清醒" |
| completion-promise | 状态文件含 "DONE" 即停止 |

## 主要实现

| 仓库                                                                              | Stars | 语言         | 特点                         |
| ------------------------------------------------------------------------------- | ----- | ---------- | -------------------------- |
| [snarktank/ralph](https://github.com/snarktank/ralph)                           | 18.2k | TypeScript | 极简外部循环，PRD 驱动，每次全新 Session |
| [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code)   | —     | —          | 工程化路线：监控仪表盘、断路器、速率限制       |
| [ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum) | —     | —          | 官方教程，三阶段流程                 |
| [umputun/ralphex](https://github.com/umputun/ralphex)                           | —     | Rust       | 独立 CLI，多阶段 review          |
| [iannuttall/ralph](https://github.com/iannuttall/ralph)                         | —     | —          | 极简文件驱动                     |

### 两种实现路线对比

| 维度 | snarktank（极简） | frankbria（工程化） |
|------|------------------|---------------------|
| 会话模式 | 每次全新 Session | 默认复用，可切换为全新 |
| 监控 | 手动 cat/jq | 内置 tmux 仪表盘 |
| 安全机制 | max_iterations | 断路器 + 速率限制 + 超时 |
| 安装方式 | Skill 复制 | install.sh + 交互向导 |
| 任务格式 | prd.json | PROMPT.md + fix_plan.md |
| 适合场景 | 长期 AFK、大量迭代 | 短中期迭代、需要实时监控 |

### Context Rot 与会话模式选择

**短任务（< 50k tokens）**：复用会话更有优势。上下文还没来得及退化，前几次迭代的记忆还能被后续利用。

**长任务（100k+ tokens）**：全新会话更可靠。超过 100k tokens 后 Context Rot 明显加剧，累积的上下文从资产变成负债。

> frankbria 用户可以根据任务规模灵活选择：短任务用默认的 `--continue` 模式，长任务切换到 `--no-continue` 模式。

## Context Rot 问题

要理解 Ralph 为什么有效，先要理解它解决的问题。

### AI 是怎么"变笨"的

用 LLM 处理复杂任务时，对话越来越长后，它开始"迟钝"——忘记重要信息，重复犯同样的错误，代码质量下降，甚至开始产生"幻觉"。

这不是 AI 不够聪明。问题在于 **上下文窗口被污染了** ——失败的代码、错误信息、不再相关的讨论占用空间，分散 AI 的"注意力"。

### Dumb Zone

| 上下文大小 | 表现 |
|-----------|------|
| 0 - 50k tokens | 最佳性能 |
| 50k - 100k tokens | 良好，轻微下降 |
| 100k+ tokens | 明显退化，开始忽略指令 |
| 150k+ tokens | 严重退化 |

经验法则：**上下文用到一半左右就该警惕了**。

## Human on the Loop

| Human **in** the Loop | Human **on** the Loop |
| --------------------- | --------------------- |
| 保姆式陪伴                 | 监督式管理                 |
| AI 每一步都等你确认           | 设定目标和边界，AI 自主运行       |
| 你是工作流程的瓶颈             | 你偶尔检查进度               |

这就像监督一个实习生——你不会站在旁边看他写每一行代码，而是给他任务、边界、检验标准，然后让他去做。

### 实际使用模式

- **AFK 模式**：下班前启动，回家睡觉，早上检查结果
- **Human-in-the-loop 模式**：每次迭代后暂停检查，适合复杂或不确定的任务

## 三种使用模式

### 完整实现模式（Full Implementation Mode）

从零开始构建一个完整的功能或项目，准备好 spec 文件和实施计划，让 Ralph 自动执行所有任务。

典型场景：构建 REST API、开发 CLI 工具、实现新功能模块

真实案例：有开发者用这种模式完成了一个价值 $50,000 的外包项目，总 API 成本仅 $297。

### 探索模式

不是所有任务都需要产出代码。有时候你需要的是理解——理解一个新接手的代码库、理解一个复杂系统的架构。

典型场景：接手陌生项目快速建立认知、为代码库生成文档、分析系统架构

### 暴力测试模式

有些 bug 知道症状、知道期望的正确行为，但找不到根本原因。让 Ralph 来"暴力破解"。

典型场景：间歇性出现的 bug、偶尔失败的测试、原因不明的性能问题

设置目标："修复这个 bug，让这个测试稳定通过"，Ralph 会不断尝试不同方案，直到找到有效的那个。

## PRD 编写原则

PRD（Product Requirements Document）的质量直接决定 Ralph 的执行效果。

### 原则一：Story 粒度要合适

经验法则：**一个 story 涉及 1-3 个文件修改，有 3-5 条验收标准**。

### 原则二：验收标准必须可自动验证

```json
// ❌ 模糊的标准
"acceptanceCriteria": ["代码质量好", "性能不错"]

// ✅ 可验证的标准
"acceptanceCriteria": [
  "pnpm types:check 通过",
  "pnpm test 通过",
  "文件 src/auth/login.ts 存在且导出 loginHandler 函数"
]
```

### 原则三：利用 dependsOn 控制顺序

```json
{
  "userStories": [
    { "id": "US-001", "dependsOn": [] },
    { "id": "US-002", "dependsOn": ["US-001"] },
    { "id": "US-003", "dependsOn": ["US-002"] }
  ]
}
```

### 原则四：在 notes 中提供上下文

notes 字段是给 AI 的额外提示。把你知道但 AI 可能不知道的信息写在这里。

## Claude Code 官方插件

```bash
/plugin install ralph-loop@claude-plugins-official
/ralph-loop:ralph-loop "Build a hello world API" --completion-promise "DONE" --max-iterations 10
/ralph-loop:cancel-ralph
```

## 与传统 AI Coding 对比

| 维度 | 传统 | Ralph Loop |
|------|------|-----------|
| 上下文 | 持续积累，污染后降级 | 每次全新，保持清晰 |
| 状态位置 | LLM 记忆 | 文件 + Git |
| 任务长度 | 受窗口限制 | 理论上无上限 |
| 失败成本 | 高 | 低 |
| 适用场景 | 短任务、补全 | 复杂系统级任务 |

## 关键洞察

- **License 不是护城河**：通过反向运行 Ralph，可以用干净-room 规格重建产品功能，不复制代码
- **上下文刷新**是关键：状态存在于文件和 Git 历史中，不存在于 LLM 记忆
- **适合复杂功能开发**，不适合快速探索

## 相关页面

- [[Harness_Engineering]] — Ralph Loop 是 Harness Engineering 的具体实现形式之一
- [[AGENTS.md]] — Ralph Loop 与 AGENTS.md 配合使用效果最佳
- [[LLM_Wiki_模式]] — Ralph 的迭代循环理念与 LLM Wiki 的增量维护思路相通