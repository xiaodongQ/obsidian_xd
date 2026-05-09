---
title: Ralph Loop
tags: [概念, AI Coding, Ralph Loop, Claude Code, 自主循环, Agent]
created: 2026-05-09
source: 01_sources/调研/Ralph_Loop_调研.md
---

# Ralph Loop

## 概述

**Ralph Loop** 是 2025 年底在 AI Coding 社区疯传的自主循环开发技术，以《辛普森一家》角色命名。其核心是将 AI 编码 Agent 包裹在 Bash while 循环中反复执行，直到满足完成条件。

> "That's the beauty of Ralph - the technique is deterministically bad in an undeterministic world."
> — Geoffrey Huntley

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

| 仓库 | Stars | 语言 | 特点 |
|------|-------|------|------|
| [snarktank/ralph](https://github.com/snarktank/ralph) | 18.2k | TypeScript | 最流行，支持 Claude Code/Amp，含浏览器验证 |
| [ghuntley/how-to-ralph-wiggum](https://github.com/ghuntley/how-to-ralph-wiggum) | — | — | 官方教程，三阶段流程 |
| [umputun/ralphex](https://github.com/umputun/ralphex) | — | Rust | 独立 CLI，多阶段 review |
| [iannuttall/ralph](https://github.com/iannuttall/ralph) | — | — | 极简文件驱动 |

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