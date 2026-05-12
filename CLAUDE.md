# 知识库维护指南

基于 **LLM Wiki 模式**运作的个人知识库。AI 维护者负责读取源文档、构建和维护 wiki 内容，用户是源材料的提供者和提问者。

## 目录结构

```
obsidian_xd/
├── 01_sources/               ← 源文档（扁平归档，不破坏原始文件）
│   ├── _clippings/          ← 外部内容入口（待处理）
│   ├── _archived/            ← 已摄入原文归档（带 source tags）
│   ├── 收藏/                ← 收藏内容（skills 等）
│   │   └── skills/          ← 可复用的 skill 文件
│   ├── 知识库设计说明/      ← 设计文档
│   └── _draft/              ← 临时草稿（不摄入）
│
├── 02_wiki/                  ← Wiki 内容（按 Topic Cluster 组织）
│   ├── _registry/            ← 规范文件
│   │   ├── SPEC.md          ← 维护规范（唯一真实源）
│   │   └── topics.json      ← Topic 注册表
│   ├── _shared/
│   │   └── _template_meta.md ← _meta.md 模板
│   ├── _topics/
│   │   └── README.md        ← 全部 Topic 一览
│   ├── Claude_Code/         ← Topic Cluster
│   │   └── _meta.md
│   ├── Harness/
│   │   └── _meta.md
│   ├── LLM_Agent/
│   │   └── _meta.md
│   └── Warp_Terminal/
│       └── _meta.md
│
└── CLAUDE.md                 ← 本文件（快速索引）
```

## Wiki 组织方式

**Topic Cluster** — 每个 wiki 归属于一个主题簇，簇内有 `_meta.md` 作为入口：

- `Claude_Code/` — Claude Code、AGENTS 模式
- `Harness/` — Harness Engineering、SPEC 设计规范
- `LLM_Agent/` — LLM Agent、RAG、Wiki 模式
- `Warp_Terminal/` — Warp Terminal

新增 Topic → 在 `topics.json` 注册 → 创建 cluster 目录 → 复制 `_template_meta.md`

## Source 管理

| 目录 | 用途 | 是否摄入 Wiki |
|------|------|--------------|
| `_clippings/` | 外部内容入口，放置待处理文档 | 是 → 摄入后归档 |
| `_archived/` | 已摄入原文，扁平存放 | 可选 |
| `收藏/` | 收藏内容（skills、工具） | 否 |

**微信文章**：存入 `_archived/`，标注 `#wechat`，正文抓取失败时 ⚠️ 标记待补全，不自动生成 Wiki。

## 快速上手（AI 维护者）

1. 用户放入新文档到 `_clippings/`
2. AI 判断 topic 归属（查 `topics.json`）
3. 创建/更新对应 cluster 内的 wiki 页面
4. 更新 cluster 的 `_meta.md`
5. 执行 `python scripts/validate_kb.py` 验收

## 详细规范

**→ `02_wiki/_registry/SPEC.md`**

## 摄入历史

```bash
git log --oneline -20 -- 01_sources/ 02_wiki/
```