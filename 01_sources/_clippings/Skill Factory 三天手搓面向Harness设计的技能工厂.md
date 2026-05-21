---
title: Skill Factory 三天手搓面向Harness设计的技能工厂
tags: [文章, AI Coding, Skill, Harness, Agent, Agent Skills, SDD, 阿里云]
created: 2026-05-21
source: https://mp.weixin.qq.com/s/tm7M3N8f45K87YUTwERkhg
source_alias: 阿里云开发者-月珩
published: 2026-05-14
---

# Skill Factory 三天手搓面向Harness设计的技能工厂

## 基本信息

| 项目 | 内容 |
|------|------|
| 作者 | 月珩 |
| 来源 | 阿里云开发者公众号 |
| 发布日期 | 2026-05-14 |
| 标签 | AI Coding / Skill / Harness Engineering / SDD |
| 原始链接 | https://mp.weixin.qq.com/s/tm7M3N8f45K87YUTwERkhg |

## 核心观点

### 背景：两种现有 Skill 生成方式的问题

| 维度 | 模式一：人工编写 | 模式二：对话生成（OpenClaw/Claude Code） |
|------|----------------|----------------------------------------|
| 核心逻辑 | 人脑驱动，完全依赖个人经验 | 对话驱动，依赖 Prompt 技巧与上下文窗口 |
| 生产效率 | 低（需天/周） | 高 |
| 代码质量 | 波动大，取决于工程师水平，风格不统一 | 随机性强，可能缺乏异常处理/类型提示 |
| 测试验证 | 无自动化闭环，需人工自行执行测试 | 无自动化闭环 |
| 多方案探索 | 单线程一次只能写一种实现，推翻重来成本高 | 串行迭代需多轮对话，上下文易丢失，难并行对比 |
| 工程化程度 | 纯人工可能格式/规范出错 | 可能缺乏生产级鲁棒性与安全规范 |
| 知识复用 | 通用逻辑重复造轮子，难抽取公共库 | 对话记录难共享，难沉淀最佳实践 |
| 核心缺陷 | 效率瓶颈 & 质量黑盒 | 不可控 & 缺乏工程验证 |

### Skill Factory 解决方案：测试驱动 + 并行生成

**核心流程：**

```
技能定义（输入技能+测试问题+API接口）
    ↓
基线诊断
    ↓
多路并发 Skill 生成（3种策略并行）
    ↓
质量检查（多维度评价）
    ↓
回归迭代（测试-优化-测试）
    ↓
标准化输出 → 适配知流平台（MCP/HTTP/Dify Agent）
```

**关键设计点：**

1. **并行多策略生成**：同时调用 3 种不同 Creator 策略（如 Anthropic 的 Skill-Creator + writing-skills 等），只要有一路生成高质量代码即为成功，极大提高 First-Time Pass Rate
2. **测试驱动开发（TDD）**：先有测试用例，再生成 Skill，自动回归验证
3. **多维度评价**：从格式规范、复用创新、功能可用性、运行稳定性、文档规范评分
4. **团队知识复用**：自动识别重复模块，建议公共库化

### 后续方向

- **基于 Trace 的 Skill 机会挖掘**（Trace2Skill）：将 Agent 执行轨迹的"隐性经验"转化为"显性知识"结构化技能文档
- **SkillRL**：把 Agent 与环境交互产生的冗长轨迹蒸馏成紧凑、可复用的"技能卡片"，在强化学习训练过程中让技能库与策略共同进化
- **虚拟环境回归**：对无法实际执行的 Skill，模拟虚拟环境让 Agent 进行测试回归

## 三种模式横向对比

| 分析维度 | 模式一：人工编写 | 模式二：对话驱动 | 模式三：Skill Factory（评测驱动） |
|----------|----------------|----------------|----------------------------------|
| 核心逻辑 | 人脑驱动，完全依赖个人经验 | 对话驱动，依赖 Prompt 技巧 | 流程驱动，标准化流水线 + TDD |
| 生产效率 | 低（需天/周，含编码/文档/手动测试） | 高 | 高 |
| 代码质量 | 波动大，风格不统一 | 随机性强，可能缺异常处理 | 标准化，下限有保证 |
| 测试验证 | 无自动化闭环 | 无自动化闭环 | **自动化闭环**，先有测试再生成 Skill，自动回归 |
| 多方案探索 | 单线程，推翻重来成本高 | 串行迭代，多轮对话，上下文易丢失 | **多路并行竞优**，同时生成 3 种策略版本择优 |
| 工程化程度 | 纯人工，规范可能出错 | 可能缺乏生产级鲁棒性 | 可注入测试逻辑/优化逻辑，达生产级交付 |
| 知识复用 | 重复造轮子，难抽取公共库 | 对话记录难共享，难沉淀最佳实践 | **自动识别重复模块**，建议公共库化，全员共享 |
| 核心缺陷 | 效率瓶颈 & 质量黑盒 | 不可控 & 缺乏工程验证 | 初期搭建成本高 |

## 参考链接

- [Anthropic Skills 官方 Repo](https://github.com/anthropics/skills)
- [OpenClaw Skill Creator](https://github.com/openclaw/openclaw/tree/main/skills/skill-creator)
- [Trae 官方 Skill 编写指南](https://docs.trae.cn/ide/best-practice-for-how-to-write-a-good-skill)
- [Superpowers Framework (writing-skills)](https://github.com/superpowerlabs/superpowers)
- [Distill Trajectory-Local Lessons into Transferable Agent Skills — 千问](https://arxiv.org/abs/xxx)（Trace2Skill 论文）

## 相关页面

- [[Agent_Skill设计模式.md]] — Skill 设计模式（Tool Wrapper/Generator/Reviewer/Inversion/Pipeline）
- [[Agent_Skills_官方规范.md]] — Agent Skills 官方规范（agentskills.io 标准）
- [[Harness_Engineering]] — Harness Engineering 核心思想
- [[Claude_Code创建插件.md]] — Claude Code 插件创建流程（_clippings 源文档）