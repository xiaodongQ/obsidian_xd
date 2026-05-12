---
title: Agent Readiness
tags: [工具, AI Coding, Agent, 工程质量, 仓库审计, Factory]
created: 2026-05-12
source: 01_sources/_archived/你的仓库对 Agent 够友好吗？Factory Agent Readiness 的开源实现.md
---

# Agent Readiness

## 概述

**Agent Readiness** 是一个静态审计工具，衡量一个 Git 仓库有多"适合 AI Agent 来干活"。丢进任何 Git 仓库，自动扫描代码结构、发现应用边界、并行评估 82 个检查项，输出 JSON 报告和 HTML Dashboard。

核心认知：**"The agent is not broken. The environment is."** — Agent 没坏，是环境有问题。Agent 表现好不好，最大的变量不是模型，而是代码仓库本身的工程基础。

开源实现：https://github.com/superduck-ai/agent-readiness

## 9 个技术支柱

| 支柱 | 解决的失败模式 |
|------|--------------|
| **Style & Validation** | 无 Linter/类型检查，Agent 在语法错误上浪费时间 |
| **Build System** | 构建命令不确定，Agent 靠猜来验证 |
| **Testing** | 无可运行测试，反馈循环断裂 |
| **Documentation** | 隐性知识未写下，Agent 只能读文档 |
| **Development Environment** | 环境不可复现，"在我机器上能跑" |
| **Debugging & Observability** | 运行时无可见性，"挂了"变"挂了因为 X" |
| **Security** | 缺自动化护栏，Agent 动作快但不安全 |
| **Task Discovery** | Issue 无结构化模板，Agent 不知要做什么 |
| **Product & Experimentation** | 无法度量影响、跑实验、理解用户行为 |

## 5 级成熟度模型

| Level | 名称 | 含义 | 通过门槛 |
|-------|------|------|----------|
| 1 | Functional | 能跑，但需手动搭建 | — |
| 2 | Documented | 基础文档和流程就位 | 当前 Level 80% |
| 3 | Standardized | 标准化，大部分团队的首个目标 | 当前 Level 80% |
| 4 | Optimized | 快速反馈循环，数据驱动 | 当前 Level 80% |
| 5 | Autonomous | 具备自我改进能力 | 当前 Level 80% |

参考数据：CockroachDB Level 4 (74%)、FastAPI Level 3 (53%)、Express Level 2 (28%)。

## 审计流程（5 阶段）

1. **仓库扫描**：检测语言、目录结构、配置文件位置
2. **应用发现**：识别 monorepo 中独立可部署的应用（38 个应用级 + 44 个仓库级检查项）
3. **并行评估**：9 个类别各派一个子 Agent 独立评估，实际执行命令确认功能可用
4. **报告校验**：Schema 校验 82 个检查项，不通过打回重做
5. **出分 + Dashboard**：计算 Level，生成 JSON + HTML 可视化报告

## 关键设计

- **不只查文件存不存在**：读配置内容、执行命令确认功能可用（如 `--listTests` 真跑测试框架）
- **每个检查项附 rationale**：解释为什么这么判、证据是什么
- **Fix 按钮**：为 failed 项生成 remediation prompt，直接丢给 Agent 执行
- **趋势追踪**：history 目录记录历史快照，Dashboard 画趋势曲线
- **不修改源文件**：所有产物在 `.agent-readiness/` 下

## 核心洞察

> 对 Agent 友好的仓库，对人也好。这从来不是对立的关系。

Agent 能力的天花板取决于落地环境。Missing pre-commit hooks 意味着 Agent 要等 10 分钟 CI 反馈而非 5 秒；没有文档的环境变量意味着 Agent 只能靠猜；构建流程全靠口口相传意味着 Agent 不知道怎么验证产出。

## 相关页面

- [[AGENTS.md]] — Agent Readiness 检查 AGENTS.md 是否存在
- [[Harness_Engineering]] — Agent Readiness 量化了 Harness 的环境就绪程度
- [[Agent_Skill设计模式]] — Skill 的 scripts/ 和 references/ 也影响 Readiness 分数
