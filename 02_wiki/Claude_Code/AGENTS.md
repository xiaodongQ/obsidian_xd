---
title: AGENTS.md
tags: [概念, AI Coding, AGENTS.md, Codex, Claude Code]
created: 2026-05-08
source: 01_sources/_archived/一个文件让AI Coding效率翻倍AGENTS.md实践指南.md
---

# AGENTS.md

## 概述

**AGENTS.md** 是在代码仓库根目录放置的 Markdown 文件，告诉 AI 工具项目是什么、怎么构建、有什么规矩。可以理解为给 AI 看的 README——README.md 给人类看，AGENTS.md 给 AI Agent 看。

## 为什么有效

| 特性 | 说明 |
|------|------|
| **No decision point** | 信息从一开始就存在于上下文中，Agent 不需要选择是否加载 |
| **Consistent availability** | 始终可用，不像 Skills 需要异步加载 |
| **Faster to iterate** | 修改 Markdown 文件比重新部署 Skill 配置快得多 |

## 最佳实践（7 个特征）

### 1. 渐进式披露优于堆砌

最好的 AGENTS.md 主文件约 **100-150 行**，外加少量聚焦引用文档。研究表明，这种结构能稳定带来 10-15% 整体提升；主文件继续膨胀时，收益开始反转。

### 2. 流程化步骤帮助大

研究数据显示，流程化步骤（Step-by-step guides）带来显著提升：
- 缺少 wiring 文件的 PR 比例：从 40% 降到 10%
- `correctness` 提升 25%
- `completeness` 提升 20%

### 3. 决策表消除歧义

决策表把"模糊偏好"改写成"显式路由规则"。

### 4. 少量真实代码示例

3-10 行的真实生产代码片段，比抽象原则更能帮助 Agent 复用现有模式。

### 5. 每个"不要"配一个"应该怎么做"

### 6. 文档边界与代码边界一致

### 7. 每个规则都要回答：Agent 下一步该做什么

## 具体配置建议

### 工具优先级

```markdown
## Tool Priority
- Filename search: `fd`
- Text/content search: `rg` (ripgrep)
- AST/structural search: `sg` (ast-grep)
```

### 搜索卫生规范

```markdown
### Search Hygiene (fd/rg/sg)
- Exclude bulky folders: `.git`, `node_modules`, `coverage`, `out`, `dist`
- Prefer running searches against a scoped path (e.g., `src`)
```

### Lint 检查闭环

```markdown
## Commands
- `make lint` - 运行所有 lint 检查
- `make test` - 运行测试
- `make verify` - 完整验证（lint + test）
```

## 迭代方法

1. **Start minimal**: 6-10 条规则，3-5 个命令引用
2. **Use agents**: 在真实任务上工作 1-2 天
3. **Note failures**: Agent 哪些地方做错了
4. **Add rules**: 把修复写入 AGENTS.md
5. **Prune**: 删除 Agent 总是正确遵循的规则
6. **Repeat**

## 与 Skills 的对比

| 场景 | 推荐方案 |
|------|---------|
| 基本约定和约束 | AGENTS.md |
| 需要编排的复杂工作流（多步部署、复杂测试套件） | Skills |

**Skills 的问题**：
- 调用措辞稍微变化，结果就完全不同
- 调用时机不对
- Agent 忘了调用
- Agent 可能没意识到自己需要帮助

## 与 Harness Engineering 的关系

AGENTS.md + lint 脚本 + 验证规范，本质上是在构建一个**反馈回路**：
> AI 读 AGENTS.md 理解项目 → 写代码 → 自动检查 → 启动验证 → 根据结果修正

人类角色是**设计这个回路**，而非在回路中每一步都亲自操作。

## 相关页面

- [[Harness_Engineering]] - AGENTS.md 是 Harness 落地的具体工具之一
- [[LLM_Wiki_模式]] - LLM Wiki 与 AI Coding 的关系
- [[Agent_Skill设计模式]] - 基本约束用 AGENTS.md，复杂工作流用 Skill
- [[Agent_Readiness]] - Agent Readiness 检查 AGENTS.md 是否存在
