---
title: Ruflo 仓库 README(ruvnet/ruflo)
source: https://github.com/ruvnet/ruflo
tags: [LLM, Agent, Claude, RAG, MultiAgent, Ruflo, Claude_Code]
status: ✅ 已摄入
date: 2026-06-09
---

# Ruflo(原 Claude Flow)— 仓库 README 摘录

> 原仓库:https://github.com/ruvnet/ruflo
> Web UI:https://flo.ruv.io/ · Goal Planner:https://goal.ruv.io/
> 版本:v3.6.30(2026-05-05)· 许可:MIT

## 项目定位

> Multi-agent AI harness for Claude Code and Codex. Orchestrate 100+ specialized AI agents across machines, teams, and trust boundaries. Ruflo adds coordinated swarms, self-learning memory, federated comms, and enterprise security to Claude Code — so agents don't just run, they collaborate.

**前身**:Claude Flow,2026 年改名 Ruflo。"Ru" 来自作者 rUv,"flo" 代表 flow state(心流)。

## 数据流(架构图)

```
User → Ruflo(CLI/MCP)→ Router → Swarm → Agents → Memory → LLM Providers
                              ↑                                        |
                              +------ Learning Loop(自学习/自优化)-------+
```

## 关键指标

| 指标 | 数值 |
|------|------|
| Stars | 27.8k ~ 48.5k(不同时间点) |
| Forks | 5k+ |
| 插件 | 32 个原生 Claude Code 插件 + 21 个 npm 插件 |
| Agent | 100+ 专业角色 |
| MCP 工具 | 210+ |
| CLI | 26 个顶层命令 / 140+ 子命令 |
| 后台 Workers | 12 个自动触发 |
| 编程语言 | TypeScript 88.2% / JS 5.1% / Shell 3.6% / Svelte 1.8% / Rust 0.6% |

## 两种安装路径(选错了就白装了)

| 维度 | A. Claude Code Plugin | B. CLI install(`npx ruflo init`) |
|------|----------------------|-----------------------------------|
| 获得 | slash commands + skills + agent 定义 | 完整闭环:98 agents / 60+ commands / 30 skills / MCP server / hooks / daemon |
| 工作区文件 | 无 | `.claude/`、`.claude-flow/`、`CLAUDE.md`、helpers、settings |
| MCP server 注册 | ❌(memory_store、swarm_init 不可用) | ✅ |
| Hooks | ❌ | ✅ |
| 适用 | 试用单个插件 | 生产环境,文档承诺"按描述工作" |

安装命令:
```bash
# A 路径
/plugin marketplace add ruvnet/ruflo
/plugin install ruflo-core@ruflo

# B 路径
npx ruflo@latest init
# 或
curl -fsSL https://cdn.jsdelivr.net/gh/ruvnet/ruflo@main/scripts/install.sh | bash

# Claude Code 中注册 MCP server
claude mcp add ruflo -- npx ruflo@latest mcp start
```

## 33 个插件分门别类

- **核心 & 编排**:core / swarm / autopilot / loop-workers / workflows / federation
- **记忆 & 知识**:agentdb / rag-memory / rvf / ruvector / knowledge-graph
- **智能 & 学习**:intelligence / graph-intelligence / daa / ruvllm / goals
- **代码质量 & 测试**:testgen / browser / jujutsu / docs
- **安全 & 合规**:security-audit / aidefence
- **架构 & 方法**:adr / ddd / sparc
- **DevOps & 可观测性**:migrations / observability / cost-tracker
- **垂直领域**:agent / plugin-creator / iot-cognitum / neural-trader / market-data

## Claude Code 单独 vs + Ruflo

| 能力 | Claude Code 单独 | + Ruflo |
|------|-----------------|---------|
| Agent 协作 | 孤立、无共享上下文 | Swarm + 共享内存 + 共识 |
| 协调 | 手动编排 | Queen-led 层级(Raft/Byzantine/Gossip)|
| 记忆 | 仅会话内 | HNSW 向量,亚毫秒检索 |
| 学习 | 静态行为 | SONA 自学习 + 模式匹配 |
| 任务路由 | 用户决定 | Q-Learning 智能路由(89% 准确率)|
| 后台 Workers | 无 | 12 个自动触发 |
| LLM 提供商 | 仅 Anthropic | 5 家 + 故障转移 |
| 跨机器协作 | 不支持 | 零信任联邦 |
| 成本 | 全部任务调 LLM | 简单任务 WASM 免费处理 |

## HNSW 向量记忆性能(官方审计数据)

- N=5k 时:3.2x ~ 4.7x 快于暴力搜索
- N=20k 时:1.9x 快于暴力搜索
- recall@10:≈ 0.99
- 见 `docs/reviews/intelligence-system-audit-2026-05-29.md`
- 反驳"ANN 只在大 N 才赢":小 N 持平/略输,大 N 明显胜出
