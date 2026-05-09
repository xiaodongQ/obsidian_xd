---
title: Ralph Loop 实现方案
tags: [AI Coding, Ralph Loop, Claude Code, Agent, 工具链]
created: 2026-05-10
source: 01_sources/_clippings/snarktankralph 实战指南.md
---

# Ralph Loop 实现方案

## 两种实现路线对比

| 维度 | snarktank/ralph（极简） | frankbria/ralph-claude-code（工程化） |
|------|------------------------|---------------------------------------|
| 会话模式 | 每次全新 Session | 默认复用，可切换为全新 |
| 上下文 | 每次全新 | 通过 `--continue` 跨迭代累积 |
| 监控 | 手动 cat/jq | 内置 tmux 仪表盘 |
| 安全机制 | max_iterations | 断路器 + 速率限制 + 超时 |
| 安装方式 | Skill 复制 | install.sh + 交互向导 |
| 任务格式 | prd.json | PROMPT.md + fix_plan.md |
| 适合场景 | 长期 AFK、大量迭代 | 短中期迭代、需要实时监控 |

## snarktank/ralph：极简路线

**核心**：几百行 bash 脚本，每次全新会话，专注于循环本身。

### 安装

```bash
# Claude Code 中直接安装 skill
/ plugin install ralph-loop@claude-plugins-official

# 或手动克隆
git clone https://github.com/snarktank/ralph.git
```

### 核心文件

| 文件 | 作用 |
|------|------|
| `ralph.sh` | 循环引擎，每次迭代启动全新 Claude 实例 |
| `prd.json` | 任务定义，所有 user stories 在这里 |
| `progress.txt` | 经验日志，每次迭代追加学到的东西 |
| `AGENTS.md` | 持久化知识库，跨项目通用知识 |

### prd.json 格式

```json
{
  "projectName": "博客 i18n 翻译",
  "branchName": "ralph/i18n-translation",
  "userStories": [
    {
      "id": "US-001",
      "title": "翻译首页元数据",
      "description": "创建 content/docs/meta.en.json",
      "acceptanceCriteria": [
        "meta.en.json 文件存在且 JSON 格式正确",
        "pnpm types:check 通过"
      ],
      "priority": 1,
      "passes": false,
      "dependsOn": []
    }
  ]
}
```

### 执行

```bash
# 默认 10 次迭代
./scripts/ralph/ralph.sh --tool claude

# 指定迭代次数
./scripts/ralph/ralph.sh --tool claude 30

# 中断后恢复，直接重新运行
./scripts/ralph/ralph.sh --tool claude 35
```

### 关键设计：验收标准必须可自动验证

```json
// ❌ 模糊
"acceptanceCriteria": ["代码质量好", "用户体验流畅"]

// ✅ 可验证
"acceptanceCriteria": [
  "pnpm types:check 通过",
  "pnpm test 通过",
  "文件 src/auth/login.ts 存在"
]
```

---

## frankbria/ralph-claude-code：工程化路线

**核心**：完整工具链——交互式配置向导、实时监控仪表盘、断路器、速率限制、会话过期管理。

### 安装

```bash
git clone https://github.com/frankbria/ralph-claude-code.git
cd ralph-claude-code
./install.sh
```

### 核心命令

```bash
ralph              # 启动循环
ralph --monitor    # 带实时监控
ralph --live       # 在 tmux 中运行（推荐长时间运行）
ralph --resume     # 从中断处继续
ralph --no-continue  # 切换为全新会话模式
```

### 目录结构

```
.ralph/
├── PROMPT.md      # 项目目标和上下文
├── fix_plan.md    # 任务清单和进度
├── AGENT.md       # 构建/测试命令（自动维护）
├── specs/         # 详细需求文档
└── sessions/      # 会话状态追踪
```

### 安全机制

| 机制 | 说明 |
|------|------|
| 断路器 | 连续无进展或相同错误时自动停止 |
| 速率限制 | 默认 100 calls/hour，防止账单爆炸 |
| 5h 限额三层检测 | Anthropic API 5h 滑动窗口限额保护 |
| 会话过期 | 默认 24h，自动清理过期上下文 |

### 智能退出检测

双条件退出门：
```
退出 = completion_indicators >= 2 AND EXIT_SIGNAL: true
```
防止 AI 说"完成"但实际只完成了当前 story 就退出。

---

## Context Rot 与会话模式选择

| 场景 | 推荐 |
|------|------|
| 短任务 < 50k tokens | frankbria 默认模式（复用） |
| 10+ 任务、长任务、AFK | snarktank 或 frankbria + `--no-continue` |
| 需要实时监控 | frankbria |
| 不确定任务量 | frankbria + `--no-continue` |

---

## 相关页面

- [[Ralph_Loop]] — Ralph Loop 概念和原理
- [[Ralph_Wiggum_深度解析]] — Context Rot 问题和三根支柱
- [[Claude_Code_质量检查流程]] — Ralph 的质量门禁参考