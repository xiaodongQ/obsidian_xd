---
title: DDD to OpenSpec
tags: [概念, DDD, OpenSpec, 领域驱动设计, 架构设计, AI Coding]
created: 2026-05-12
source: 01_sources/_archived/Domain Driven Design to OpenSpec：从领域模型到工程规范衔接实践.md
---

# DDD to OpenSpec

## 概述

**DDD to OpenSpec** 定义了领域驱动设计（DDD）产出物向 OpenSpec 规范化工作流转化的标准映射路径。将 DDD 的领域洞察力与 OpenSpec 的结构化执行力结合，建立从模型到代码的高可靠衔接体系。

核心关系：DDD 提供"道"（分析复杂业务领域的思维），OpenSpec 提供"术"（将领域设计高效、可验证地转化为工程成果）。

## 战略对齐：用"领域"组织"规范"

### 限界上下文 ↔ 领域目录

DDD 的限界上下文在 OpenSpec 中对应为 `specs/` 目录下的子领域目录，确保每个业务边界在工程规格中有明确归属。

### config.yaml 全景视图

在 `openspec/config.yaml` 中声明映射关系，为 AI Agent 提供全局架构上下文，使其理解所属业务边界。

## 战术落地：构造块映射

| OpenSpec 结构 | DDD 产出物 | 说明 |
|--------------|-----------|------|
| 领域（Domain） | 限界上下文 | 一个领域目录 = 一个限界上下文 |
| 需求（Requirement） | 领域服务 / 命令 | 一个核心业务功能或操作 |
| 场景（Scenario） | 聚合行为 | Given/When/Then (Gherkin) 格式 |
| 技术设计（Design） | 应用服务 | 协调多个领域服务，管理事务与安全 |
| 实施任务（Tasks） | 战术设计待办 | 实体、值对象、仓储接口等 |

> **防呆约定**：每个 Requirement 聚焦一个可独立验证的业务能力。需要 5 个以上 Scenario 或覆盖多个聚合根时，应拆分。

## 工作流生命周期

| 阶段 | DDD 对应 | 说明 |
|------|----------|------|
| Propose（提案） | 领域建模 | `/opsx:propose` 初始化变更，沉淀建模结论 |
| Apply（实施） | 规范驱动开发 | AI 依据 Requirement + Scenario 进行代码实现与验证 |
| Archive（归档） | 知识合并 | Delta Spec 合并至主规范，确保单一事实来源 |

> **避免微瀑布**：小步快跑——规范片段与代码实现尽早合流，不要等模型"完美"再进入 Apply。

## 核心机制

### AI 动态指令体系（OPSX）

AI 主动查询 CLI 了解项目状态（当前限界上下文边界、已有聚合定义），做出符合领域约束的决策。

### 结构化校验与自动化验证

- **Schema 校验**：确保 Requirement 和 Scenario 格式正确
- **自动化验证闭环**：AI 基于 Spec 生成集成测试，验证代码是否符合 DDD 不变量

## 最佳实践

### 通用语言贯穿执行

编写 proposal.md、design.md、spec.md 时必须严格使用通用语言。config.yaml 确保术语在每次 AI 请求中作为"上下文锚点"被精准引用。

### 场景驱动的 BDD 风格验证

> **业务规则优先原则**：Scenario 只描述业务规则与不变量，不得渗入技术细节。技术细节归入 design.md 或 tasks.md。保持 Scenario 的领域纯洁性是 AI 正确生成领域层代码和测试的前提。

### Delta 与变更管理

在 `changes/` 目录下并行开发不同领域特性，只关注当前变更受影响的能力。

## 附录：事件驱动最终一致性范式

### 何时发布事件

- **跨聚合一致性**：只在命令直接作用的聚合内同步更新，发布事件异步更新其他聚合
- **跨上下文集成**：领域事件作为契约出口
- **触发时机**：聚合状态落库后、事务提交时发布（推荐 Outbox 模式）

### 如何消费事件

- **幂等消费**：携带幂等键（AggregateId + Version），防重复投递
- **失败策略**：进入重试/死信队列，不回滚上游；补偿逻辑通过补偿事件完成
- **上下文翻译**：跨上下文消费需经防腐层（ACL）翻译语义

### 核心约束

> 一次事务只修改一个聚合。跨聚合一致性通过事件与补偿完成。

## 相关页面

- [[Harness_Engineering]] — OpenSpec 是 Harness 中规范驱动的实现
- [[Agent_Skill设计模式]] — OpenSpec 的场景驱动与 Skill 的结构化行为设计相通
- [[LLM智能体外部化综述]] — 协议是交互结构的外部化
