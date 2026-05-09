---
title: Warp Terminal
tags: [工具, AI Terminal, Agentic, Rust, 开发环境]
created: 2026-05-09
source: 01_sources/调研/Warp_Terminal_调研.md
---

# Warp Terminal

## 概述

**Warp** 是一个用 Rust 构建的 GPU 加速终端，从 2026 年起定位为 **Agentic Development Environment**（Agentic 开发环境）。2026 年开源（AGPL v3 + MIT），GitHub 突破 **50,000 Stars**，超过 70 万开发者使用。支持的平台：macOS、Linux、Windows（Windows 11 专用安装包 via Warp 官方 fork 的 Microsoft Terminal）。

> "Warp 不再是终端，而是一个 Agent 工作空间。"
> — XDA Developers

> ⚠️ **平台说明**：早期 Warp 仅 macOS，2026 年已扩展至 Linux 和 Windows。Windows 版通过 warpdotdev/microsoft-terminal 分支提供，仅支持 Windows 11。

## 核心定位演变

| 版本 | 定位 | 核心差异 |
|------|------|----------|
| 1.x | 现代终端 | GPU 加速 + Block UI + 协作 |
| AI 集成 | AI 辅助命令 | 自然语言 → Shell、错误解释 |
| 2.0 | Agentic 开发环境 | **完全开源** + Oz 云端 Agent + MCP |

## 核心功能

### Agent Mode（核心）
自然语言命令 → LLM 解析 → 执行（可选人工审批）。可自动纠正错误并重试，直到任务完成。

### Oz 云端 Agent
后台运行，可响应 Webhooks、CI 事件、Slack 消息，实现"无人值守"。

### MCP 支持
一级支持，连接外部工具生态（数据库、Git、CI 系统）。

### 其他功能
- **Block UI**：命令输出分块展示，可折叠/搜索/复制
- **Natural Language Commands**：直接说"部署这个"，生成对应命令
- **Error Explanation**：错误即 LLM 解释
- **Shared Workflows**：团队共享命令流程
- **Command Palette**：Cmd+K 命令面板

## 竞品对比

### 终端层面

| 维度 | Warp 2.0 | Ghostty | WezTerm |
|------|----------|---------|---------|
| AI 原生 | ✅ | ❌ | ❌ |
| 开源 | AGPL v3+MIT | MIT | MPL 2.0 |
| 协作 | ✅ | ❌ | ❌ |
| tmux 兼容 | ❌ | ✅ | ✅ |

### Agentic 开发环境层面

| 维度 | Warp 2.0 | Intent (Augment Code) |
|------|----------|----------------------|
| 架构 | 终端原生，Oz Agents | Living specs + 多 Agent 协调 |
| 模型 | BYOK | 闭源 |
| MCP | ✅ 一级支持 | 需配置 |

## 与 Ralph Loop 的关系

Warp Agent Mode（内置循环）与 Ralph Loop（外部 Bash 循环）本质相同：
- 都是文件状态驱动
- 都强调上下文刷新
- Warp 是 Ralph Loop 的天然前端

## 参考链接

- 官网：https://www.warp.dev/
- GitHub：https://github.com/warpdotdev/warp
- Agent Mode：https://www.warp.dev/ai

## 相关页面

- [[Ralph_Loop]] — Warp Agent Mode 是 Ralph Loop 的内置实现
- [[Harness_Engineering]] — Warp 可作为 Harness Engineering 的终端层