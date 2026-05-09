---
title: "snarktank/ralph 实战指南"
source: "https://yudesk.dev/docs/notes/ralph-wiggum/snarktank"
author:
  - "[[wuyuxiangX]]"
published:
created: 2026-05-09
description: "极简外部循环实现：PRD 编写、循环执行、质量门禁与经验复盘"
tags:
  - "clippings"
---
Ralph Wiggum

AI 辅助写的182 次浏览

极简外部循环实现：PRD 编写、循环执行、质量门禁与经验复盘

## 引言

[上一篇](https://yudesk.dev/docs/notes/ralph-wiggum/concept) 我们了解了 Ralph 的核心原理——无限循环 + 每次全新上下文 + 文件作为真相来源。三根支柱听起来简单，但从理解到实际跑通之间还有不少细节。

这一篇，我们来动手操作。 [snarktank/ralph](https://github.com/snarktank/ralph) 是 Ralph 方法论的 **外部循环实现** ——每次迭代启动一个全新的 Claude 进程，彻底解决 Context Rot 问题。它是目前社区中最完善的 Ralph 实现之一（10k+ stars），支持 Claude Code 和 Amp 双平台，提供了 PRD 生成、JSON 转换、自动执行的全套工具链。

> 另一种实现路线是 [frankbria/ralph-claude-code](https://yudesk.dev/docs/notes/ralph-wiggum/frankbria) ，提供完整的工程化工具链（监控仪表盘、断路器、速率限制），侧重可控性和安全机制。两者的对比见该文。

## 前置要求

在开始之前，确保你的环境满足以下条件：

| 依赖 | 说明 |
| --- | --- |
| **AI 编程工具** | Claude Code (`npm install -g @anthropic-ai/claude-code`) 或 Amp CLI |
| **jq** | JSON 处理工具（macOS: `brew install jq` ） |
| **Git** | 项目需要是 Git 仓库 |

```
# 检查依赖
claude --version   # Claude Code CLI
jq --version       # JSON 处理
git --version      # Git
```

## 安装与配置

最简单的方式——在 Claude Code 对话中直接粘贴 GitHub 链接：

```
帮我安装这个 skill：https://github.com/snarktank/ralph
```

Claude Code 会自动克隆仓库并将 skill 文件复制到正确位置。安装完成后即可使用 `/prd` 和 `/ralph` 命令。

> snarktank/ralph 还支持 Marketplace 安装、手动复制 skill 文件、项目级安装等方式，详见 [GitHub 仓库说明](https://github.com/snarktank/ralph) 。

---

## 核心文件结构

Ralph 的记忆完全依赖文件系统。理解每个文件的作用是用好 Ralph 的前提。

![Ralph 核心文件结构总览：ralph.sh、prd.json、progress.txt、AGENTS.md 四个文件的关系和数据流向](https://wyx-shanghai.oss-cn-shanghai.aliyuncs.com/2026-03/1773028627721.png)

Ralph 的四个核心文件及其协作关系

### ralph.sh — 循环引擎

这是 Ralph 的核心：一个 bash 脚本，负责反复启动新的 AI 实例。

```
# 基本用法
./scripts/ralph/ralph.sh [max_iterations]        # 默认使用 Amp
./scripts/ralph/ralph.sh --tool claude [iterations]  # 使用 Claude Code
```

每次迭代，ralph.sh 做这些事：

1. 创建功能分支（基于 prd.json 中的 `branchName` ）
2. 选择最高优先级的未完成 story（ `passes: false` ）
3. 启动一个 **全新的** AI 实例来实现这个 story
4. 运行质量检查（类型检查、测试）
5. 检查通过 → git commit；失败 → 留给下一次迭代
6. 更新 prd.json，标记 story 为 `passes: true`
7. 在 progress.txt 中追加本次学到的经验
8. 重复，直到所有 story 完成或达到迭代上限
<svg style="z-index: 0;"><g tabindex="0" role="group" aria-roledescription="edge" data-id="e-pass" data-testid="rf__edge-e-pass" aria-label="Edge from quality-check to git-commit" aria-describedby="react-flow__edge-desc-1"><path marker-end="url('#1__type=arrowclosed')" d="M637,135 C605.0546875,135 605.0546875,135 573.109375,135" fill="none" style="stroke: rgb(34, 197, 94);"></path><g transform="translate(595.0503158569336 128.66059637069702)" visibility="visible"><rect width="28.008743286132812" x="-4" y="-4" height="20.678807258605957" rx="2" ry="2" style="fill: white; fill-opacity: 0.9;"></rect><text y="6.3394036293029785" dy="0.3em" style="fill: rgb(22, 163, 74); font-weight: 600;">通过</text></g></g></svg> <svg style="z-index: 0;"><g tabindex="0" role="group" aria-roledescription="edge" data-id="e-fail" data-testid="rf__edge-e-fail" aria-label="Edge from quality-check to fail-retry" aria-describedby="react-flow__edge-desc-1"><path marker-end="url('#1__type=arrowclosed')" d="M861.359375,135 C879.1796875,135 879.1796875,25 897,25" fill="none" style="stroke: rgb(239, 68, 68);"></path><g transform="translate(869.1753158569336 73.66059637069702)" visibility="visible"><rect width="28.008743286132812" x="-4" y="-4" height="20.678807258605957" rx="2" ry="2" style="fill: white; fill-opacity: 0.9;"></rect><text y="6.3394036293029785" dy="0.3em" style="fill: rgb(220, 38, 38); font-weight: 600;">失败</text></g></g></svg> <svg style="z-index: 0;"><g tabindex="0" role="group" aria-roledescription="edge" data-id="e-fail-loop" data-testid="rf__edge-e-fail-loop" aria-label="Edge from fail-retry to select-story" aria-describedby="react-flow__edge-desc-1"><path marker-end="url('#1__type=arrowclosed')" d="M996.828125 -3L996.828125 -4L 996.828125,-18Q 996.828125,-23 991.828125,-23L 280.328125,-23Q 275.328125,-23 275.328125,-18L275.328125 -3" fill="none" style="stroke: rgb(239, 68, 68); stroke-dasharray: 5, 5;"></path><g transform="translate(616.0764579772949 -29.33940362930298)" visibility="visible"><rect width="48.003334045410156" x="-4" y="-4" height="20.678807258605957" rx="2" ry="2" style="fill: white; fill-opacity: 0.9;"></rect><text y="6.3394036293029785" dy="0.3em" style="fill: rgb(220, 38, 38); font-weight: 500;">下轮重试</text></g></g></svg> <svg style="z-index: 0;"><g tabindex="0" role="group" aria-roledescription="edge" data-id="e-loop" data-testid="rf__edge-e-loop" aria-label="Edge from all-done to select-story" aria-describedby="react-flow__edge-desc-1"><path marker-end="url('#1__type=arrowclosed')" d="M378 355L358 355L 280.328125,355Q 275.328125,355 275.328125,350L275.328125 73L275.328125 53" fill="none" style="stroke: rgb(111, 66, 193);"></path><g transform="translate(240.33404922485352 207.66059637069702)" visibility="visible"><rect width="77.98815155029297" x="-4" y="-4" height="20.678807258605957" rx="2" ry="2" style="fill: white; fill-opacity: 0.9;"></rect><text y="6.3394036293029785" dy="0.3em" style="fill: rgb(111, 66, 193); font-weight: 600;">否：继续下一个</text></g></g></svg> <svg style="z-index: 0;"><g tabindex="0" role="group" aria-roledescription="edge" data-id="e-done" data-testid="rf__edge-e-done" aria-label="Edge from all-done to complete" aria-describedby="react-flow__edge-desc-1"><path marker-end="url('#1__type=arrowclosed')" d="M552.6328125,355 C574.81640625,355 574.81640625,355 597,355" fill="none" style="stroke: rgb(34, 197, 94);"></path><g transform="translate(569.8142204284668 348.660596370697)" visibility="visible"><rect width="18.004371643066406" x="-4" y="-4" height="20.678807258605957" rx="2" ry="2" style="fill: white; fill-opacity: 0.9;"></rect><text y="6.3394036293029785" dy="0.3em" style="fill: rgb(22, 163, 74); font-weight: 600;">是</text></g></g></svg>

1\. 创建功能分支

2\. 选择下一个 Story

3\. 启动全新 AI 实例

4\. 实现 Story

5\. 质量检查 types / test / build

6\. Git Commit passes → true

留给下轮迭代 记录失败原因

7\. 更新 progress.txt 追加本轮经验

全部完成? 或达到上限?

8\. 完成! COMPLETE

[React Flow](https://reactflow.dev/)

默认迭代上限是 10 次。根据项目复杂度调整：

```
# 简单项目
./scripts/ralph/ralph.sh --tool claude 10

# 复杂项目
./scripts/ralph/ralph.sh --tool claude 50
```

### prd.json — 任务定义

这是 Ralph 的"大脑"——所有任务都在这里定义。格式是一个扁平的 JSON 文件：

```
{
  "projectName": "博客 i18n 翻译",
  "branchName": "ralph/i18n-translation",
  "userStories": [
    {
      "id": "US-001",
      "title": "翻译首页元数据",
      "description": "创建 content/docs/meta.en.json，包含所有导航项的英文翻译",
      "acceptanceCriteria": [
        "meta.en.json 文件存在且 JSON 格式正确",
        "所有导航标题都已翻译为英文",
        "pnpm types:check 通过"
      ],
      "priority": 1,
      "passes": false,
      "dependsOn": [],
      "notes": "参考现有 meta.json 的结构"
    },
    {
      "id": "US-002",
      "title": "翻译博客文章 hello-world",
      "description": "创建 content/blog/hello-world.en.mdx，从中文翻译为英文",
      "acceptanceCriteria": [
        "hello-world.en.mdx 文件存在",
        "所有 QuoteCard 组件设置 defaultLang='en'",
        "内部链接使用 /en/ 前缀",
        "代码块保持不翻译",
        "pnpm types:check 通过"
      ],
      "priority": 2,
      "passes": false,
      "dependsOn": ["US-001"],
      "notes": "注意保留 MDX 组件的 props 格式"
    }
  ]
}
```

**字段说明** ：

| 字段 | 说明 |
| --- | --- |
| `projectName` | 项目名称，用于日志和分支命名 |
| `branchName` | Git 分支名，Ralph 会自动创建 |
| `id` | Story 唯一标识，建议用 `US-001` 格式 |
| `title` | 简短标题 |
| `description` | 详细描述，越具体越好 |
| `acceptanceCriteria` | 验收标准列表—— **这是最关键的字段** |
| `priority` | 优先级数字，越小越先执行 |
| `passes` | 是否已完成，Ralph 自动更新 |
| `dependsOn` | 依赖的 story ID 列表 |
| `notes` | 额外备注和提示 |

### progress.txt — 经验日志

这是 Ralph 的"长期记忆"。每次迭代结束后，AI 会在这里追加本轮学到的内容：

```
=== Iteration 1 (US-001) ===
- Discovered: typecheck command is \`pnpm types:check\`, not \`pnpm typecheck\`
- Discovered: meta.en.json needs to mirror exact structure of meta.json
- Pattern: fumadocs i18n uses \`.en.\` suffix convention

=== Iteration 2 (US-002) ===
- Discovered: QuoteCard requires both \`quote\` and \`quoteZh\` props
- Gotcha: internal links must use /en/ prefix for English pages
- Pattern: code blocks should never be translated
```

下一次迭代的新 Claude 实例会读取这个文件，立即获得之前所有的经验。这就是 Ralph 能越跑越顺的原因—— **知识在迭代间积累，但上下文保持干净** 。

### AGENTS.md — 持久化知识库

除了 progress.txt，Ralph 还会更新项目中的 `AGENTS.md` 文件（或 `CLAUDE.md` ）。Claude Code 和 Amp 都会在启动时自动读取这些文件。

与 progress.txt 不同，AGENTS.md 记录的是 **稳定的、跨项目通用的知识** ：

```
# AGENTS.md

## Codebase Conventions
- Use fumadocs for documentation framework
- MDX files use custom components: QuoteCard, BlogImage, GlossaryCard
- i18n files use \`.en.mdx\` suffix

## Gotchas
- Always run \`pnpm types:check\` after modifying MDX files
- QuoteCard: set \`defaultLang='en'\` in English translations
```

---

## 编写 PRD

PRD（Product Requirements Document）的质量直接决定 Ralph 的执行效果。写得好，Ralph 一路畅通；写得差，Ralph 会在同一个 story 上反复失败。

### 使用 Skill 生成 PRD

如果你安装了 snarktank/ralph 的 skill，可以用交互式方式生成 PRD：

```
# 在 Claude Code 或 Amp 中
/prd 我想为博客系统添加 i18n 支持，需要将所有中文内容翻译成英文
```

AI 会向你提出一系列澄清问题（涉及哪些文件、技术栈约束、质量标准等），然后生成结构化的 PRD 文档。

生成后，使用 `/ralph` 命令将 PRD 转换为 `prd.json` 格式：

```
/ralph    # 将 PRD 转换为 prd.json
```

### 手动编写 PRD

你也可以直接编写 prd.json。以下是关键的设计原则。

**原则一：Story 粒度要合适**

每个 story 应该小到能在一次迭代中完成，大到有独立的交付价值。

```
// ❌ 太大：一次迭代完不成
{
  "id": "US-001",
  "title": "构建完整的用户认证系统",
  "description": "实现注册、登录、忘记密码、OAuth、权限管理..."
}

// ❌ 太小：没有独立价值
{
  "id": "US-001",
  "title": "创建 User 表的 email 字段",
  "description": "在 User 模型中添加 email 字段"
}

// ✅ 合适：一次能完成，有独立价值
{
  "id": "US-001",
  "title": "实现邮箱密码登录",
  "description": "创建登录 API 和登录页面，支持邮箱密码验证",
  "acceptanceCriteria": [
    "POST /api/auth/login 接受 email + password",
    "返回 JWT token",
    "登录页面表单可提交",
    "所有测试通过"
  ]
}
```

**经验法则** ：一个 story 涉及 1-3 个文件修改，有 3-5 条验收标准。

**原则二：验收标准必须可自动验证**

Ralph 需要判断 story 是否完成，所以验收标准必须是可以客观判断的：

```
// ❌ 模糊的标准
"acceptanceCriteria": [
  "代码质量好",
  "性能不错",
  "用户体验流畅"
]

// ✅ 可验证的标准
"acceptanceCriteria": [
  "pnpm types:check 通过",
  "pnpm test 通过",
  "API 响应时间 < 200ms",
  "文件 src/auth/login.ts 存在且导出 loginHandler 函数"
]
```

**原则三：利用 dependsOn 控制顺序**

有些 story 之间有依赖关系。 `dependsOn` 字段确保 Ralph 按正确顺序执行：

```
{
  "userStories": [
    {
      "id": "US-001",
      "title": "创建数据库 schema",
      "dependsOn": []
    },
    {
      "id": "US-002",
      "title": "实现用户注册 API",
      "dependsOn": ["US-001"]
    },
    {
      "id": "US-003",
      "title": "实现登录页面",
      "dependsOn": ["US-002"]
    }
  ]
}
```

**原则四：在 notes 中提供上下文**

notes 字段是给 AI 的额外提示。把你知道但 AI 可能不知道的信息写在这里：

```
{
  "notes": "项目使用 fumadocs 框架，i18n 文件命名规则是 .en.mdx 后缀。参考 content/docs/notes/speckit/concept.en.mdx 的翻译风格。"
}
```

---

## 执行 Ralph Loop

PRD 准备好了，开始跑循环。

### 启动执行

```
# 使用 Claude Code，默认 10 次迭代
./scripts/ralph/ralph.sh --tool claude

# 指定迭代次数
./scripts/ralph/ralph.sh --tool claude 30

# 使用 Amp（默认）
./scripts/ralph/ralph.sh 20
```

### 执行过程

启动后，你会看到类似这样的输出：

```
Starting Ralph - Tool: claude - Max iterations: 35

===============================================================
  Ralph Iteration 1 of 35 (claude)
===============================================================
## US-001 Complete

**Summary of what was done:**
1. Created meta.en.json with all navigation items translated
2. Ran pnpm types:check — PASSED
3. Committed: feat: [US-001] - Translate homepage metadata

There are still **15 user stories with \`passes: false\`** remaining.
The next story is **US-002: 翻译博客文章 hello-world**.
Iteration 1 complete. Continuing...

===============================================================
  Ralph Iteration 2 of 35 (claude)
===============================================================
```

每次迭代都是一个全新的 Claude 实例。它通过读取 prd.json 知道当前要做什么，通过 progress.txt 知道之前学到了什么。

### 完成信号

当所有 story 都标记为 `passes: true` 时，Ralph 会输出完成信号并退出：

```
All stories completed!
<promise>COMPLETE</promise>
```

### 监控与调试

在 Ralph 运行时，你可以用这些命令查看进度：

```
# 查看各 story 的完成状态（带图标，更直观）
cat tasks/prd.json | python3 -c "
import json,sys
for s in json.load(sys.stdin)['userStories']:
    print(f'{\"✅\" if s[\"passes\"] else \"⬜\"} {s[\"id\"]}: {s[\"title\"]}')"

# 或者用 jq 查看
cat tasks/prd.json | jq '.userStories[] | {id, title, passes}'

# 查看经验日志
cat progress.txt

# 查看最近的 git 提交
git log --oneline -10

# 实时查看 Ralph 的输出
tail -f progress.txt

# 完成后，查看相比主分支的全部改动
git diff main...ralph/your-branch-name --stat
```

### 中断与恢复

Ralph 运行时间可能很长，中途中断是完全安全的：

- **中断** ：直接 `Ctrl+C` ，已完成的 story（ `passes: true` ）不会丢失，它们已经 commit 并写入 prd.json
- **恢复** ：再次运行同样的命令，Ralph 会自动从第一个 `passes: false` 的 story 继续

```
# 中断后恢复，只需重新运行同样的命令
./scripts/ralph/ralph.sh --tool claude 35
```

如果某个 story 反复失败导致阻塞，你可以手动跳过它——编辑 `prd.json` ，将该 story 的 `passes` 字段改为 `true` ，然后重新运行。Ralph 会跳过它，继续处理后续 story。

### 自动归档

当你用新的 `branchName` 启动一个不同的功能时，Ralph 会自动将上一次运行的文件归档到 `archive/YYYY-MM-DD-feature-name/` 目录，保持工作目录整洁。

---

## 反馈循环与质量门禁

Ralph 的"自我纠错"能力完全取决于反馈循环的质量。没有反馈循环的 Ralph 就是一个盲目循环的脚本——它会不断产出代码，但无法判断代码是否正确。

### 配置质量检查

在 CLAUDE.md（或 prompt.md）中定义你的质量检查命令：

```
## Quality Commands

After implementing each story, run these checks IN ORDER:

1. \`pnpm types:check\` — TypeScript type checking
2. \`pnpm test\` — Unit tests
3. \`pnpm build\` — Full build verification

If any check fails:
- DO NOT commit
- Fix the issue
- Re-run all checks
- Only commit when all checks pass
```

### 质量门禁的层次

| 层次 | 工具 | 捕获的问题 |
| --- | --- | --- |
| 即时反馈 | TypeScript compiler | 类型错误、语法错误 |
| 功能验证 | 单元测试 | 逻辑错误、边界情况 |
| 集成验证 | Build 命令 | 依赖问题、配置错误 |
| 运行时验证 | dev-browser skill | UI 渲染问题（前端项目） |

> 对于前端 story，Ralph 建议在验收标准中加入："Verify in browser using dev-browser skill"——让 AI 实际打开浏览器确认页面渲染正确。

### 当质量检查失败时

如果某个 story 的质量检查反复失败，Ralph 不会无限重试同一个 story。到达迭代上限后，它会停止并留下当前状态。你可以：

1. 检查 progress.txt 看看 AI 卡在什么地方
2. 手动修复问题后重新运行
3. 调整 story 的粒度（可能拆分得太大了）
4. 补充 notes 提供更多上下文

### Prompt 定制

Ralph 的 prompt 模板（CLAUDE.md 或 prompt.md）是你控制 AI 行为的主要手段。安装后，你应该根据自己的项目定制它。关键定制方向：

**代码风格约束**

```
## Code Conventions
- Use TypeScript strict mode
- Prefer named exports over default exports
- Use fumadocs components for MDX content
- Follow existing file naming patterns (kebab-case)
```

**常见陷阱**

```
## Known Gotchas
- MDX files: always import components at the top
- i18n: English files use \`.en.mdx\` suffix
- Links: English pages must use \`/en/\` prefix
- QuoteCard: set \`defaultLang\` to match the file language
```

**卡住时的处理方式**

```
## When Stuck
If you cannot complete a story after 3 attempts within the same iteration:
1. Document what's blocking in progress.txt
2. Move to the next story if possible
3. Do NOT modify files unrelated to the current story
```

---

## 实战案例：用 Ralph 完成博客 i18n 翻译

为了展示 Ralph 在实际项目中的运作方式，这里分享一个真实案例：使用 Ralph 风格的自主 agent 将整个博客从中文翻译成英文。

### 项目设置

项目需要将 22+ 个内容文件（博客文章、文档、导航元数据）从中文翻译成英文，目标是基于 fumadocs 的 Next.js 博客 i18n 支持。任务定义在一个 `prd.json` 文件中，包含 16 个 user story，每个都有明确的验收标准：

```
scripts/ralph/
├── prd.json          # 16 个 user story，含验收标准
└── progress.txt      # 经验日志，每完成一个 story 后更新
```

每个 user story 遵循一致的模式：

- **明确的交付物** ："Create content/blog/xxx.en.mdx"
- **可验证的标准** ："Typecheck passes"、"Internal links use /en/ prefix"
- **技术约束** ："Keep code blocks untranslated"、"Set defaultLang='en' on QuoteCard"

### 执行模式

Agent 遵循 Ralph 方法论的核心原则：

1. **文件即真相来源** ： `prd.json` 跟踪每个 story 的状态（ `passes: true/false` ）。 `progress.txt` 在迭代中积累经验——比如 "Typecheck 命令是 `pnpm types:check` ，不是 `pnpm typecheck` "
2. **自动化质量门禁** ：每次翻译完成后，运行 `pnpm types:check` 验证 MDX 文件能正确编译。如果 typecheck 失败，先修复问题再提交。
3. **增量推进** ：每个 story 独立提交，使用描述性的 commit message（ `feat: [US-003] - Translate blog/claude-code-quality-control.mdx` ），方便在需要时回滚。
4. **并行执行** ：对于较长的文章，多个 subagent 同时翻译——比如 US-010（claude-skills concept + practice）、US-011（speckit concept + practice）和 US-012（claude-architecture + claude-subagent）同时并行运行。

### 关键经验

| 经验 | 详情 |
| --- | --- |
| **知识积累很重要** | 早期 story 发现的模式（QuoteCard 的 `defaultLang` 、链接前缀规则）让后续 story 更快完成 |
| **Typecheck 作为反馈循环** | 在问题叠加之前捕获缺失的 import 或格式错误的 MDX |
| **并行化可以扩展** | 6 个翻译 agent 同时运行，完成时间与 1 个差不多 |
| **PRD 粒度至关重要** | 每个 story 限定在 1-2 个文件——小到足以可靠完成，大到足以有意义 |
| **进度日志防止重复犯错** | `progress.txt` 的 "Codebase Patterns" 部分成了知识库，避免重新踩坑 |

### 成果

16 个 user story 在单次会话中全部完成：创建了 8 个 meta.en.json 导航文件、翻译了 3 篇博客文章、翻译了 12 个文档页面、完整站点构建验证通过。每次翻译都保持了一致的质量，因为验收标准是明确的，反馈循环（typecheck）能立即发现问题。

这个项目展示了 Ralph 的 **完整实现模式（Full Implementation Mode）** ——定义清晰的任务、明确的成功标准、自动化验证，以及通过文件系统进行增量交付。

---

## 最佳实践与常见问题

### 成本控制

Ralph 的自动化执行意味着 API 成本是持续产生的。几个控制手段：

- **始终设置 `max_iterations`** ：这是最基本的安全网
- **Story 粒度合理** ：太大的 story 会消耗多次迭代；太碎的 story 增加启动开销
- **先小规模测试** ：新项目先用 3-5 次迭代试跑，确认 prompt 和质量门禁工作正常后再放开

### 常见陷阱

**陷阱 1：Story 太大**

症状：一个 story 反复失败，迭代次数很快耗尽。

解决：拆分成 2-3 个更小的 story。"构建完整的认证系统"拆成"实现登录 API"+"创建登录页面"+"添加 JWT 中间件"。

**陷阱 2：没有反馈循环**

症状：Ralph 声称 story 完成了，但实际代码有问题。

解决：在验收标准中加入可执行的检查命令。"代码写好了"不是验收标准，"pnpm test 全部通过"才是。

**陷阱 3：progress.txt 没有被利用**

症状：同一个错误在不同迭代中反复出现。

解决：确认 prompt 模板中有明确指示"读取 progress.txt 并遵循其中的经验"。如果 AI 没有自动追加学习内容，在 prompt 中加入"After each story, append learnings to progress.txt"。

**陷阱 4：依赖顺序错误**

症状：某个 story 依赖的代码还不存在，导致实现失败。

解决：正确设置 `dependsOn` 字段，确保基础设施 story 排在前面。

### 常见问题

**Q: 能不能手动修改 prd.json 中途干预？**

可以。Ralph 每次迭代开始时都会重新读取 prd.json。你可以在迭代间隙修改 story 描述、添加新 story、或手动标记某个 story 为 `passes: true` （跳过它）。

**Q: 如果 Ralph 卡在一个 story 上反复失败怎么办？**

1. 检查 progress.txt 看失败原因
2. 补充 notes 提供更多上下文
3. 拆分 story（可能粒度太大）
4. 手动修复阻塞问题后重新运行

**Q: Ralph 运行时我可以做其他事吗？**

可以。Ralph 设计为"Human on the Loop"——你不需要盯着它。AFK 模式下，下班前启动，第二天检查结果就行。运行时不要修改 Ralph 正在操作的文件即可。

**Q: 如何控制成本？**

三种方式：设置合理的 `max_iterations` 、保持 story 粒度合适（减少无效迭代）、以及先小规模试跑确认流程无误。一般来说，10-20 个 story 的项目在 $50-100 的 API 成本范围内。

---

## 小结

Ralph 的使用流程可以归纳为五步：

```
安装 → 编写 PRD → 配置质量门禁 → 执行循环 → 检查成果
```

核心思路始终不变： **让文件成为真相来源，让每次迭代都是全新开始，让质量门禁替你把关** 。

现在，回到你的项目，准备好 prd.json，运行 `./scripts/ralph/ralph.sh --tool claude` ，然后去喝杯咖啡吧。

### 延伸阅读

- 《 [Ralph Wiggum 深度解析](https://yudesk.dev/docs/notes/ralph-wiggum/concept) 》— 回顾 Ralph 的核心原理
- 《 [frankbria/ralph-claude-code 实战指南](https://yudesk.dev/docs/notes/ralph-wiggum/frankbria) 》— 工程化的 Ralph 实现：监控、断路器与安全机制
- 《 [GSD 深度解析](https://yudesk.dev/docs/notes/gsd/concept) 》— 在 Ralph 基础上构建的完整上下文工程系统
- 《 [Claude Skills 是什么](https://yudesk.dev/docs/notes/claude-skills/concept) 》— Ralph 的 PRD skill 就是一个 Claude Skill
- 《 [Speckit 实践指南](https://yudesk.dev/docs/notes/speckit/practice) 》— 另一种结构化的 AI 编程工作流

## 评论[Ralph 深度解析](https://yudesk.dev/docs/notes/ralph-wiggum/concept)

[

理解 Ralph 技术的核心原理：为什么一个 bash 循环能让 AI 在你睡觉时写代码

](https://yudesk.dev/docs/notes/ralph-wiggum/concept)[

frankbria 版实战

工程化的 Ralph 循环实现：交互式配置、实时监控、断路器与安全机制

](https://yudesk.dev/docs/notes/ralph-wiggum/frankbria)