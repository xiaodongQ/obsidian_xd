---
title: LLM Wiki 模式
tags: [概念, 知识管理, RAG, AI, LLM, Obsidian]
created: 2026-04-29
source: 01_sources/_archived/490万浏览量的方案：用 LLM 构建持续更新积累的个人知识库-腾讯云开发者社区-腾讯云 1.md
---

# LLM Wiki 模式

## 核心思想

大多数人的 LLM 文档使用方式：上传文件 → 检索相关片段 → 生成答案。

**问题**：每次提问，LLM 都要从零开始重新发现知识。没有积累。

LLM Wiki 的思路不同：**让 LLM 持续构建和维护一个 wiki**，一个结构化的、相互链接的 markdown 文件集合，基于原始素材。

> 知识被编译一次，然后保持更新，而不是每次查询都重新推导。

## 三层架构

| 层级 | 名称 | 作用 | 谁负责 |
|------|------|------|--------|
| 第一层 | Raw Sources（原始素材） | 文章、论文、图片、数据文件。只读，LLM 只读不改 | 你 |
| 第二层 | Wiki（维基） | AI 生成的摘要、实体页、概念页、对比页、概览、综合。LLM 完全拥有这一层 | LLM |
| 第三层 | Schema（说明书） | CLAUDE.md，告诉 LLM wiki 如何组织、遵循什么约定、工作流 | 你 + LLM |

## 三个核心操作

### Ingest（摄入）

把新来源丢进 raw collection → LLM 读取 → 与你讨论关键收获 → 在 wiki 中写摘要页 → 更新索引 → 更新相关实体和概念页 → 在日志追加记录。

**关键**：一个来源可能触及 10-15 个 wiki 页面。

### Query（查询）

向 wiki 提问 → LLM 搜索相关页面 → 阅读它们 → 综合出带引用的答案。

答案可以有多种形式：markdown 页面、对比表格、幻灯片（Marp）、图表（matplotlib）、canvas。

**关键洞察**：好的答案可以回存到 wiki 中成为新页面。

### Lint（健康检查）

定期让 LLM 检查 wiki 健康状况：
- 页面之间的矛盾
- 被新来源取代的过时声明
- 没有入链的孤儿页面
- 被提及但缺少独立页面的重要概念
- 缺失的交叉引用

## 两个辅助文件

### index.md（内容导向）

wiki 中所有内容的目录——每个页面带链接、一句话摘要、可选元数据。按类别组织（实体、概念、来源等）。

### log.md（时间导向）

追加式记录：发生了什么、何时发生。格式：

```
## [2026-04-02] ingest | Article Title
```

这样可以用 unix 工具解析：

```bash
grep "^## \[" log.md | tail -5  # 最近5条记录
```

## 六个实用技巧

1. **Obsidian Web Clipper**：浏览器扩展，把网页文章转成 markdown
2. **图片本地化**：附件文件夹路径固定，快捷键下载当前文件所有图片
3. **图谱视图**：Obsidian 的 graph view 查看 wiki 形状
4. **Marp**：基于 markdown 的幻灯片格式
5. **Dataview**：对页面 frontmatter 运行查询，生成动态表格和列表
6. **Git 版本控制**：wiki 即 markdown 文件的 git 仓库

## 两个瓶颈及解决思路

### 查询瓶颈

当 wiki 超过几百页后，grep 变慢。

**解决**：双层架构（Wiki 兼容 Obsidian + Memvid 层机器查询，<5ms）

### 结构瓶颈

无论是否计划，结构都会悄然形成。

**解决**：从结构化数据入手，直接渲染成 Markdown（Binder 方案）

## 与 RAG 的区别

| 维度 | RAG | LLM Wiki |
|------|-----|---------|
| 知识积累 | 无，每次重新推导 | 有，持续编译 |
| 交叉引用 | 无 | 有，AI 自动维护 |
| 矛盾标记 | 无 | 有，标记不一致处 |
| 维护成本 | 低（索引后不管） | 高（AI 持续更新） |
| 适用场景 | 简单问答 | 深度研究、长期积累 |

## 本知识库的实际应用

本知识库（obsidian_xd）采用 LLM Wiki 模式：

```
01_sources/      ← Raw Sources（只读）
02_wiki/         ← AI 生成的 Wiki
CLAUDE.md        ← Schema（说明书）
```

摄入流程：用户放入新文档 → AI 阅读 → 与用户讨论要点 → 增量整合进 Wiki 页面。

详见 [[Harness_Engineering]] 和 [[AGENTS.md]] 的 AI Coding 实践。

## 相关页面

- [[RAG_对比]] — LLM Wiki 与 RAG 的详细对比
- [[Harness_Engineering]] — AI Coding 领域的 Harness 实践
- [[Ralph_Loop]] — Ralph Loop 与 LLM Wiki 的迭代维护思路相通