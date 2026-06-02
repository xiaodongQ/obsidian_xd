# 知识库维护规范 v1.0

> 本文件是知识库的**唯一真实源（Single Source of Truth）**
> CLAUDE.md 是面向人类的索引，本文件是 AI 维护者的执行手册

---

## 一、Scheme 版本

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-05-13 | 初始版本，基于 Topic Cluster 重构 |

---

## 二、Topic 归属判定规则

### Rule 1：新 wiki 页面的归属
读取 `topics.json` 中所有 `sourceTags`，匹配页面标题/内容关键词，匹配到 → 归入对应 cluster

### Rule 2：触发新建 Topic 的条件（同时满足）
- 该内容主题与所有现有 Topic 的 `sourceTags` 匹配度均 < 30%
- 相关 source 文档 ≥ 1 篇
- 用户明确提出是独立主题

### Rule 3：多匹配时优先级
以 `sourceTags` 中匹配词数最多者为准

### Rule 4：SPEC/DDD 类 → Harness
所有涉及"规范设计"、"SPEC"、"DDD"标签的 source 和 wiki → `Harness/` 簇

### Rule 5：RAG 类 → LLM_Agent
所有涉及"RAG"、"检索增强"、"知识库"标签的 → `LLM_Agent/` 簇

---

## 三、Source 管理规则

### 微信文章处理
- mp.weixin.qq.com 文章存入 `_archived/`，标注 `#wechat` 标签
- **不自动生成 Wiki**：正文无法抓取时，只保留标题+链接，标记 ⚠️ 待补全
- 如用户明确要求生成 Wiki，状态为 `⚠️ 待补全`

### Source 标签格式（头部 YAML）
```markdown
---
title: 文章标题
source: https://原始链接
tags: [topic-tag, wechat]
status: ✅ 已摄入 | ⚠️ 待补全
date: 2026-05-13
---
```

### 归档时机
- Source 存入 `_archived/` 后即视为已归档
- Wiki 生成不是归档的前置条件

### _archived/ 内容规则
- `_archived/` 目录内的 source 文件**不摄入**（不生成 wiki）
- 归档是最终状态，文件不再参与 wiki 生成流程

---

## 四、_meta.md 格式规范

每个 Topic Cluster 必须包含以下章节：

```markdown
# {TopicName}

## 基本信息
- 创建时间：YYYY-MM-DD
- 来源数量：N
- Wiki 页面数量：N

## 关联 Sources

| 文件名 | 标签 | 状态 |
|--------|------|------|
| source文件.md | #tag | ✅ 已摄入 / ⚠️ 待补全 |

## 关联 Wiki

- `页面A.md` — 说明
- `页面B.md` — 说明

## 知识小结

> 本簇核心知识点

## 待补全
- [ ] 任务描述
```

---

## 五、Wiki 命名规范

- ✅ 使用中文描述性命名：`质量检查流程.md`
- ✅ 下划线分隔：`LLM_Wiki_模式.md`
- ❌ 不允许：空格、特殊字符（除 `-` `_` `.`）
- ❌ 不允许：纯英文文件名

---

## 六、目录结构

```
02_wiki/
├── _registry/
│   ├── SPEC.md           ← 本规范
│   └── topics.json       ← Topic 注册表
├── _shared/
│   └── _template_meta.md ← _meta.md 模板
├── _topics/
│   └── README.md         ← 全部 Topic 一览
├── Claude_Code/          ← Topic Cluster
│   └── _meta.md
├── Harness/
│   └── _meta.md
├── LLM_Agent/
│   └── _meta.md
└── Warp_Terminal/
    └── _meta.md

scripts/
└── validate_kb.py        ← 验收脚本
```

---

## 七、CLAUDE.md 的定位

CLAUDE.md 是面向人类的"快速上手 + 索引"，精简版。
详细执行规范以本文件（SPEC.md）为准。

---

## 八、Scheme 变更流程

1. 更新本文件（SPEC.md）
2. 更新 topics.json（如有新增 Topic）
3. 执行 `python scripts/validate_kb.py`
4. 全量 V1-V10 通过
5. 提交 PR / 用户确认