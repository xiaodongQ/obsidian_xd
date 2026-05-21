---
title: Anthropic Agent Skills 官方规范
tags: [概念, AI Coding, Skill, Agent, Anthropic, 规范, Claude Code]
created: 2026-05-21
source: https://agentskills.io/specification.md + agentskills.io/best-practices.md
---

# Anthropic Agent Skills 官方规范

## 概述

Anthropic Agent Skills 是 Anthropic 于 2025 年 12 月发布的**开放标准**，旨在让 AI Agent 动态加载技能包以提升专项能力。Skill 不是 Prompt，而是围绕任务、工具、流程和输出边界的**结构化行为设计**。

该标准已被 **30+ 个 AI 产品**采纳，包括：Claude Code、Claude (API)、GitHub Copilot、Cursor、Gemini CLI、VS Code (Copilot)、OpenAI Codex、OpenHands、Junie、Firebender、Spring AI、Roo Code、Mux、Letta、Goose、Factory、Databricks Genie Code 等。

> 官网：[agentskills.io](https://agentskills.io)（规范主页）
> 官方示例库：[github.com/anthropics/skills](https://github.com/anthropics/skills)
> Claude Code 插件市场注册：`/plugin marketplace add anthropics/skills`

---

## 目录结构

```
skill-name/
├── SKILL.md          # ★ 必需：YAML 元数据 + Markdown 指令
├── scripts/          # 可选：可执行脚本
├── references/       # 可选：按需加载的参考文档
├── assets/          # 可选：模板、资源文件
└── ...              # 任意附加文件或目录
```

---

## SKILL.md 格式

文件包含 YAML frontmatter（必填） + Markdown 正文（指令）。

### Frontmatter 字段

| 字段 | 必填 | 约束 |
|------|------|------|
| `name` | ✅ | 1-64 字符；小写字母、数字、连字符；不能以连字符开头/结尾；不能有连续连字符；必须与目录名一致 |
| `description` | ✅ | 1-1024 字符；描述 skill 做什么 + 何时使用；应包含触发关键词 |
| `license` | ❌ | 许可证名称或指向打包许可证文件的引用 |
| `compatibility` | ❌ | 1-500 字符；注明环境要求（产品/系统包/网络访问等） |
| `metadata` | ❌ | 任意 key-value 映射，存放附加元数据 |
| `allowed-tools` | ❌ | 实验性；预批准可运行的工具列表（空格分隔） |

### Description 写作要点

**Agent 触发完全依赖 description 字段**，由模型自主判断（Model-driven Activation）。写作规范：
- 使用祈使语气："Use this skill when..."
- 聚焦用户**意图**，而非 Skill 内部机制
- 适当"强势"，覆盖用户可能的各种表述
- 应包含具体关键词帮助 Agent 识别相关任务

> ⚠️ **重要**：Description 只应描述触发条件，**不要总结工作流程**。当 description 总结了工作流程时，Agent 可能直接按 description 执行而跳过阅读完整 SKILL.md 内容。

### name 字段格式规范

```yaml
# ✅ 合法示例
name: pdf-processing
name: data-analysis
name: code-review

# ❌ 非法示例
name: PDF-Processing      # 不能有大写
name: -pdf               # 不能以连字符开头
name: pdf--processing   # 不能有连续连字符
```

---

## 三层渐进式加载（核心机制）

| 层级 | 加载内容 | 触发时机 | Token 成本 |
|------|----------|----------|-----------|
| **L1 目录层** | `name` + `description` | 会话启动时（所有 Skill 同时加载） | 每个 ~50-100 tokens |
| **L2 指令层** | 完整 SKILL.md body | Skill 被激活时 | 建议 <5000 tokens |
| **L3 资源层** | `scripts/`、`references/`、`assets/` | 指令引用时按需加载 | 视文件大小 |

**关键价值**：即使安装了 20 个 Skill，初始加载也仅 ~1000-2000 tokens，相比单体式提示词上下文减少约 **90%**。

Agent 会在认为 Skill 相关时读取完整 `SKILL.md`，然后根据指令需要访问 `references/` 等资源文件（按需加载）。

---

## scripts/ 目录规范

可执行脚本，Agent 可自行决定调用。

编写原则：
- 自包含或明确标注依赖
- 包含有意义的错误信息
- 优雅处理边缘情况

支持语言取决于 Agent 实现（常见：Python、Bash、JavaScript）。

---

## references/ 目录规范

附加文档，Agent 需要时读取。建议结构：
- `REFERENCE.md` — 详细技术参考
- `FORMS.md` — 表单模板或结构化数据格式
- 领域特定文件（`finance.md`、`legal.md` 等）

> 文件引用保持一层嵌套深度，避免深层引用链。Agent 通过 SKILL.md 中的相对路径引用加载。

---

## assets/ 目录规范

静态资源：
- 模板（文档模板、配置模板）
- 图片（图表、示例）
- 数据文件（查找表、Schema）

Agent 通过 `SKILL.md` 引用这些文件，文件仅在引用时加载。

---

## 验证工具

使用 [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) 验证 Skill：

```bash
skills-ref validate ./my-skill
```

验证项：`SKILL.md` frontmatter 有效性、name 命名规范。

---

## Skill 创建最佳实践

### 从真实专业能力出发

避免让 LLM 凭空生成 Skill——结果往往是泛泛的"最佳实践"而非具体 API 模式和项目约定。

**高效方法**：
1. **从真实任务中提取**：与 Agent 协作完成任务，提供纠正和偏好，事后将可复用模式提取为 Skill
2. **从已有项目材料中合成**：将内部文档、Runbook、代码审查评论、故障报告喂给 LLM 合成 Skill——比通用文章更精准因为捕获了你的 Schema、故障模式和恢复流程

### 用真实执行迭代改进

第一版 Skill 通常需要修订：
- 用真实任务运行 Skill，将结果（不只是失败）反馈给创建流程
- 读 Agent 执行**过程**，不只是最终输出——Agent 在不相关步骤上浪费时间通常说明指令太模糊或包含不适用于当前任务的指令

### 控制 Context 消耗

Skill 激活后，整个 `SKILL.md` body 加载进 Agent 上下文窗口，与对话历史、其他 Active Skill 竞争注意力。

**原则**：只添加 Agent 没有你就不知的内容，删除 Agent 已知的。

```markdown
<!-- ❌ 太冗余 — Agent 已知 PDF 是什么 -->
## Extract PDF text
PDF（便携式文档格式）是常见的文件格式，包含文本、图片和其他内容。
要提取 PDF 文本，你需要使用库，推荐 pdfplumber...

<!-- ✅ 更佳 — 直接给 Agent 不知道的 -->
## Extract PDF text
使用 pdfplumber 提取文本。对于扫描文档，回退到 pdf2image + pytesseract。
```

### Scope 设计原则

Skill 应该封装一个**内聚的工作单元**，与其他 Skill 组合良好：
- 过窄 → 单个任务需加载多个 Skill，增加开销和冲突风险
- 过宽 → 难以精确激活

### 四种 Skill 类型

| 类型 | 定义 | 测试方法 | 成功标准 |
|------|------|----------|----------|
| **纪律执行型** | 强制遵守规则（如 TDD） | 压力场景 | 最大压力下仍遵守规则 |
| **技术指导型** | 具体方法的操作指南 | 应用场景 | 正确应用到新场景 |
| **思维模式型** | 解决问题的心智模型 | 识别场景 | 正确判断何时/如何应用 |
| **参考资料型** | API 文档、命令参考 | 检索场景 | 找到并正确应用信息 |

### Calibrating Control

**在以下情况给 Agent 自由度**：多方案可行、任务容忍变化。解释"为什么"比硬性指令更有效。

**在以下情况强制规范**：操作脆弱、一致性重要、必须按特定顺序执行。

### 高价值内容：Gotchas 区

Skill 中最高价值的内容往往是"Gotchas"列表——具体的环境特定事实，打破 Agent 的合理假设：

```markdown
## Gotchas
- `users` 表使用软删除，查询必须包含 `WHERE deleted_at IS NULL`，
  否则结果包含已停用账户
- 用户 ID 在数据库是 `user_id`，在认证服务是 `uid`，
  在账单 API 是 `accountId`——三者指向同一值
- `/health` 端点在 Web 服务运行时返回 200，
  即使数据库连接已断开。检查完整服务健康用 `/ready`
```

### 其他实用模式

**输出格式模板**（比描述性 prose 更可靠，Agent 模式匹配能力强）：
```markdown
## Report structure
使用此模板，按需调整各节：
# [分析标题]
## 执行摘要
[关键发现的单段落概述]
## 关键发现
- 发现 1 + 支持数据
- 发现 2 + 支持数据
## 建议
1. 具体可操作的建议
2. 具体可操作的建议
```

**多步工作流检查清单**：
```markdown
## 表单处理工作流
进度：
- [ ] 第 1 步：分析表单（运行 `scripts/analyze_form.py`）
- [ ] 第 2 步：创建字段映射（编辑 `fields.json`）
- [ ] 第 3 步：验证映射（运行 `scripts/validate_fields.py`）
- [ ] 第 4 步：填写表单（运行 `scripts/fill_form.py`）
- [ ] 第 5 步：验证输出（运行 `scripts/verify_output.py`）
```

**验证循环**：
```markdown
## 编辑工作流
1. 执行编辑
2. 运行验证：`python scripts/validate.py output/`
3. 如果验证失败：
   - 查看错误信息
   - 修复问题
   - 重新运行验证
4. 仅当验证通过时继续
```

---

## 与 Claude Code Plugin 的关系

Claude Code 的 `/plugin` 系统基于 Agent Skills 标准构建：

| 维度 | Agent Skills 标准 | Claude Code Plugin |
|------|-------------------|-------------------|
| 本质 | 开放标准格式 | Claude Code 的插件系统实现 |
| 市场 | agentskills.io 生态 | `/plugin marketplace` |
| 安装 | 各产品自行实现 | `/plugin install` 命令 |
| 能力 | 通用 Skill 加载 | Skill + MCP Server + Agent 扩展 |

Claude Code 将 Agent Skills 封装为自己的 Plugin 格式，支持：
- **Skills** — 指令型技能（标准 Agent Skills）
- **MCP Servers** — 工具型扩展（通过 `plugin.json` 配置）
- **Agents** — 行为型扩展（自定义 Agent 配置）

```bash
# 注册 marketplace
/plugin marketplace add anthropics/skills

# 安装插件集
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills

# 直接使用 Skill
# "Use the PDF skill to extract the form fields from path/to/some-file.pdf"
```

---

## 官方示例 Skill（anthropics/skills）

预构建示例（Apache 2.0 / 源码可用）：
- **Creative & Design**：art、music、design skills
- **Development & Technical**：testing web apps、MCP server generation
- **Enterprise & Communication**：communications、branding skills
- **Document Skills**：`skills/docx`、`skills/pdf`、`skills/pptx`、`skills/xlsx`（驱动 Claude 文档编辑能力，源码可用但非开源）

---

## 相关页面

- [[Agent_Skill设计模式.md]] — 设计模式视角（Google ADK 五种模式、Skill-Creator 方法论）
- [[Claude_Code]] — Claude Code 完整技术参考
- [[LLM智能体外部化综述]] — 论文视角：技能是程序化专长的外部化
- [[Harness_Engineering]] — Skill 是 Harness 的能力外部化实现