---
title: Claude Code 质量检查流程
tags: [AI Coding, Claude Code, 质量工程, DevOps, 最佳实践]
created: 2026-05-10
source: 01_sources/_archived/我的 Claude Code 质量检查流程.md
---

# Claude Code 质量检查流程

## 概述

AI 编程效率提升 2-3 倍，但也带来新挑战：**AI 生成的代码需要更严格的质量检查**。盲目信任 AI 输出会付出高昂的调试代价。

核心原则：**AI 的输出需要验证，而不是盲目信任**。

## 五层质量防线

| 防线 | 检查方式 | 触发时机 | 作用 |
|------|----------|----------|------|
| 第一道 | Hooks 自动检查 | 代码编写完成后 | 保证代码风格一致 |
| 第二道 | 测试策略 | 功能实现后 | 发现逻辑问题 |
| 第三道 | 本地 AI Review | 大改动时 | 获得即时反馈 |
| 第四道 | Pre-commit Hook | 提交前 | 防止低质量代码入库 |
| 第五道 | GitHub 集成 | PR 时 | 最后审查门槛 |

## 代码组织：按功能而非技术层

**推荐：按功能组织**

```
src/
├── user/
│   ├── router.py      # FastAPI 路由
│   ├── service.py     # 业务逻辑
│   ├── models.py      # 数据库模型
│   ├── schemas.py     # Pydantic 验证
│   └── CLAUDE.md      # 模块特定规范
└── order/
    └── ...
```

**为什么按功能组织对 AI 更友好？**

按技术层组织时，AI 修改评论功能需要读取 4 个不同目录的文件（`routers/review.py`、`services/review_service.py`、`models/review_model.py`、`schemas/review_schema.py`）。按功能组织时，所有相关文件都在 `src/review/` 下，AI 可以一次性理解整个模块的上下文。

## Make 命令统一入口

每个项目的第一件事：创建 Makefile，让 AI 记住和使用统一的命令接口。

```
.PHONY: help setup dev run stop format check test clean

help:   ## 显示帮助信息
    @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

setup:  ## 初始化开发环境（安装依赖 + git hooks）
    @uv sync && uv run pre-commit install

check:  ## 代码检查 + 类型检查 + 测试
    @echo "🔍 Checking code..." && ruff check . && mypy . && pytest

test:   ## 运行测试
    @echo "🧪 Running tests..." && pytest

format: ## 格式化代码
    @echo "🎨 Formatting code..." && black . && ruff check --fix .
```

**为什么有效？**
- 统一命令接口：无论技术栈，`make format`、`make test` 始终有效
- AI 友好：Claude 更容易记住简洁命令
- 强制规范：团队成员都知道该运行什么

## 测试策略

### 关于 Mock

**能不 Mock 就不 Mock**。Mock 测试通过了不代表真实环境能跑。AI 写测试时容易"配合"自己的代码——为了让测试通过而写，而不是真正验证边界情况。集成测试能更有效地发现问题。

必须 Mock 的场景：付费 API、时间相关逻辑、不稳定的第三方服务。

### 覆盖率

目标 80%，覆盖核心逻辑。修改某个模块时，跑 `pytest tests/user/` 快速验证，不用等全量测试。

### 测试规范模板

```
## 测试规范
- 实现新功能时，先写测试，确认测试失败，再写实现代码
- 每次修改后运行 `make test` 确保没有破坏现有功能
- 不要为了让测试通过而修改测试本身
- 外部 API、时间相关逻辑使用 Mock，其他优先真实依赖
```

## Pre-commit Hook 配置

用 pre-commit 框架配合 `make check`，配置：

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: make-check
        name: Run make check
        entry: make check
        language: system
        pass_filenames: false
```

运行 `make setup` 后，每次 `git commit` 都会自动触发 `make check`。

## Claude Code 质量检查工作流

```
用户请求 → Claude Code 实现 → Hooks 自动格式化 → AI Review（如需）
→ Pre-commit 检查 → GitHub PR 审查 → 合并
```

## 相关页面

- [[AGENTS.md]] — AGENTS.md 是质量规范的载体
- [[Harness_Engineering]] — 质量检查流程是 Harness Engineering 的具体实践
- [[Ralph_Loop]] — Ralph Loop 的反馈循环（质量门禁）与此流程相通