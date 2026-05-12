---
title: Agent Skill 设计模式
tags: [概念, AI Coding, Skill, Agent, 设计模式, Anthropic, Google]
created: 2026-05-12
source: 01_sources/_archived/Agent Skill规范、构建与设计模式.md
---

# Agent Skill 设计模式

## 概述

**Skill** 是一种可复用的 Prompt 增强包，通过渐进式加载机制为 Agent 注入领域知识和工作流程。Skill 不是 Prompt——它是围绕任务、工具、流程和输出边界的结构化行为设计。

2025 年 12 月，Anthropic 将 Skill 规范作为开放标准发布，已被 33+ 个 Agent 产品采纳（Claude Code、OpenAI Codex、GitHub Copilot、Cursor、Gemini CLI 等）。

## Skill 规范标准

### 最小形态

```bash
skill-name/
├── SKILL.md          # 必需：YAML 元数据 + Markdown 指令
├── scripts/          # 可选：可执行脚本
├── references/       # 可选：按需加载的参考文档
└── assets/           # 可选：模板、资源文件
```

### SKILL.md 格式

YAML frontmatter 必填字段：
- **name**：唯一标识，1-64 字符，小写+连字符，必须与目录名一致
- **description**：描述做什么、何时使用，≤1024 字符，应包含触发关键词

Markdown 正文：核心指令，建议 ≤500 行，超出部分拆到 references/

### 三层渐进式加载

| 层级 | 加载内容 | 加载时机 | Token 成本 |
|------|----------|----------|-----------|
| L1 目录层 | name + description | 会话启动时 | 每个 Skill ~50-100 tokens |
| L2 指令层 | 完整 SKILL.md body | Skill 被激活时 | 建议 <5000 tokens |
| L3 资源层 | scripts/、references/、assets/ | 指令引用时按需 | 视文件大小 |

关键价值：即使安装了 20 个 Skill，初始加载也仅 1000-2000 tokens，相比单体式提示词上下文使用量减少约 **90%**。

### 触发机制

Skill 触发完全依赖 description 字段，由模型自主判断（Model-driven Activation）。写作要点：
- 使用祈使语气："Use this skill when..."
- 聚焦用户意图，而非 Skill 内部机制
- 适当"强势"，覆盖用户可能的各种表述

> **重要发现**：Description 只应描述触发条件，绝不要总结工作流程。当 description 总结了工作流程时，Agent 可能直接按 description 执行而跳过阅读完整 Skill 内容。

## Skill-Creator 核心思想

Anthropic 官方的"用来创建 Skill 的 Skill"，设计哲学：**像做机器学习一样做 Prompt Engineering**——有训练集、测试集、评估指标、迭代优化循环、防过拟合机制。

三个核心思想：
1. **泛化而非过拟合** — Skill 要面对无数种 prompt，不能只为测试用例做针对性修改
2. **解释"为什么"而非堆砌"必须"** — LLM 有良好的心智理论，解释原因比写满大写 ALWAYS/NEVER 更有效
3. **提取重复模式** — 如果所有测试用例中 Agent 都独立写了类似辅助脚本，应将其放入 scripts/ 目录

### 三个专业化 Agent

| 角色 | 职责 | 核心设计 |
|------|------|----------|
| **Grader** | 评估断言是否通过，并评价评估本身 | "自我批评"：对薄弱断言给出"通过"比无用更糟，它制造虚假信心 |
| **Comparator** | 在不知道来源的情况下盲比较 A/B | 去偏见化，借鉴医学双盲实验 |
| **Analyzer** | 事后分析 WHY 赢家赢了 | 揭盲后分析指令差异和执行模式差异 |

### 已知局限

1. **Token 消耗极高** — 20 个评估 × 3 次运行 = 60 个 Opus 会话，消耗约 69% 的 5 小时配额
2. **流程冗长** — 对简单 Skill，手写 SKILL.md 比用 Skill-Creator 快得多
3. **操作型 Skill 触发率 0%** — "运行部署脚本"类 Skill，Claude 本身就能直接处理
4. **Skill 膨胀风险** — 5KB → 50KB，违背"保持精简"初衷

## Writing-Skills（Superpowers 框架）

采用 RED-GREEN-REFACTOR 循环（借鉴 TDD）：

- **RED**：不带 Skill 运行压力场景，记录 Agent 的合理化借口
- **GREEN**：针对具体失败编写最小 Skill
- **REFACTOR**：Agent 找到新借口？逐一添加明确反驳

### 四种 Skill 类型

| 类型 | 定义 | 测试方法 | 成功标准 |
|------|------|----------|----------|
| 纪律执行型 | 强制遵守规则（如 TDD） | 压力场景 | 最大压力下仍遵守规则 |
| 技术指导型 | 具体方法的操作指南 | 应用场景 | 正确应用到新场景 |
| 思维模式型 | 解决问题的心智模型 | 识别场景 | 正确判断何时/如何应用 |
| 参考资料型 | API 文档、命令参考 | 检索场景 | 找到并正确应用信息 |

## 五种设计模式（Google ADK）

### 模式一：Tool Wrapper

给 Agent 装"技能包"。SKILL.md 不包含完整规范，而是告诉 Agent 去哪里加载。适用：封装框架/库的编码规范、团队代码风格。

### 模式二：Generator

填空题式文档生成。模板 + 风格指南强制输出一致性。关键：Agent 不会瞎猜，缺什么直接问。适用：标准化文档生成。

### 模式三：Reviewer

代码审查自动化。检查清单独立维护，Agent 只负责执行打分。关键：不只指出问题，还要解释为什么是问题。适用：自动化 PR 审查。

### 模式四：Inversion

让 Agent 先问你。翻转传统交互——Agent 先采访用户收集完整需求后再动手。适用：新项目规划、需求不明确时。

### 模式五：Pipeline

带检查点的多步工作流。每步都有输入/输出和通过条件，用户不点头 Agent 不能往下走。适用：多阶段内容生产。

### 模式选择与组合

| 你需要什么？ | 选择 |
|-------------|------|
| 特定技术栈专家知识 | Tool Wrapper |
| 一致的结构化输出 | Generator |
| 自动化审查 | Reviewer |
| 需先收集信息 | Inversion |
| 复杂多步任务 | Pipeline |
| 不确定？ | 从 Tool Wrapper 开始 |

常见组合：Pipeline + Reviewer、Generator + Inversion、Pipeline + Tool Wrapper

## 关键结论

1. Skill 不是 Prompt，而是围绕任务、工具、流程和输出边界的结构化行为设计
2. 渐进式加载是核心机制，解决了 Agent 系统的上下文膨胀问题
3. Description 是触发的关键，写好 description 比写好指令主体更重要
4. 生态已形成 规范标准 → 构建方法论 → 设计模式 的完整知识体系

## 相关页面

- [[Harness_Engineering]] — Skill 是 Harness 的能力外部化实现
- [[AGENTS.md]] — AGENTS.md 与 Skill 互补：基本约束用 AGENTS.md，复杂工作流用 Skill
- [[LLM智能体外部化综述]] — 论文视角：技能是程序化专长的外部化
