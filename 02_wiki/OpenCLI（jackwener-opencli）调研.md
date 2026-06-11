---
title: OpenCLI（jackwener/opencli）调研
date: 2026-06-11
tags: [调研, CLI, AI-Agent, 浏览器自动化, MCP]
source: https://github.com/jackwener/opencli
---

# OpenCLI（jackwener/opencli）调研

> 📅 2026-06-11 调研
>
> ⚠️ 名字撞车提醒：另有一个 **OpenCLI Specification (OCS)** 项目（spectreconsole/open-cli，v0.1 草案，描述 CLI 接口的规范），详见 [[OpenCLI Specification（OCS v0.1）调研]]。本笔记说的是下面这个工程化项目。

## 一句话定位

**把任意网站、本地 CLI、Electron 应用统一成一个 CLI 表层**，让人类和 AI Agent 都能用同一套命令去操作；同时自带 Browser Bridge，让 AI 借助**你已登录的 Chrome**去做点击、填表、提取数据。

官方口号：**"Make Any Website into CLI & Use your logged-in browser by AI agent."**

## 三类用法

1. **内建适配器**（直接用）
   - B 站、知乎、小红书、Reddit、HackerNews、Twitter/X 等
   - 用法：`opencli hackernews top --limit 5`

2. **AI Agent 调用**（核心卖点）
   - 装 `opencli-browser` skill 到 Claude Code / Cursor 等 agent
   - agent 可通过**已登录的 Chrome** navigate / click / fill / extract
   - 不靠截图，靠结构化 DOM snapshot

3. **写自定义适配器**
   - `opencli-adapter-author` skill 端到端引导：recon → 选 pattern（SPA/SSR/JSONP/Token/Streaming）→ 选 auth（PUBLIC/COOKIE/INTERCEPT/UI/LOCAL）→ 写 adapter → verify
   - 站点知识持久化到 `~/.opencli/sites/<site>/`

## 工作机制

- **本地守护进程** + **Chrome 扩展**（Browser Bridge）通过 19825 端口通信
- 支持多 Chrome profile，命令 `opencli profile list` / `opencli profile use work`
- 浏览器命令格式：`opencli browser <session> <subcommand>`
  - 子命令：`open / state / click / type / fill / select / keys / wait / get / find / extract / frames / screenshot / scroll / back / eval / network / tab list / tab new / tab select / tab close / init / verify / close`

## 本地 CLI 也能挂上来

- `opencli external register mycli` —— 把任意本地 CLI 暴露到 OpenCLI 的发现层
- 已注册：gh、docker、longbridge、tg、discord、wx、ntn（Notion）等
- 还支持 Electron app 适配器：Cursor、Trae CN、Codex、Antigravity、ChatGPT、Trae SOLO

## 适配器管理 4 条路径

| 需求 | 推荐做法 |
|---|---|
| 自己的网站命令放私人 git 仓 | `opencli plugin create` + `opencli plugin install file://...` |
| 快速起草私人 adapter | `opencli browser init <site>/<command>` 写到 `~/.opencli/clis/` |
| 本地修改官方 adapter | `opencli adapter eject` + `opencli adapter reset` |
| 发布/安装第三方命令 | `opencli plugin install github:user/repo` |

## 安装

```bash
# 1. 确认 Node.js >= 20
node --version

# 2. 全局装 CLI
npm install -g @jackwener/opencli

# 3. 装 Chrome 扩展（推荐走商店）
# https://chromewebstore.google.com/detail/opencli/ildkmabpimmkaediidaifkhjpohdnifk
# 离线：Releases 下载 opencli-extension-v{version}.zip → 加载已解压扩展

# 4. 自检
opencli doctor

# 5. 装 skill 到 AI Agent
npx skills add jackwener/opencli
# 按需装单个：--skill opencli-browser / opencli-adapter-author / opencli-autofix / opencli-browser-sitemap / opencli-sitemap-author / opencli-usage
```

## 6 个 Skill 速查

| Skill | 用途 | 示例 prompt |
|---|---|---|
| opencli-usage | 命令与站点速查 | "OpenCLI 都有哪些 Twitter 命令？" |
| opencli-browser | 驱动 Chrome 做 ad-hoc 操作 | "帮我看看小红书的通知" |
| opencli-browser-sitemap | 借 sitemap 上下文驱动浏览器 | "按 sitemap 走，不盲点" |
| opencli-sitemap-author | 创建/更新站点 sitemap 知识 | "把你刚发现的工作流记下来" |
| opencli-adapter-author | 端到端写新 adapter | "给抖音热榜写个 adapter" |
| opencli-autofix | 修坏掉的 adapter | "opencli zhihu hot 返回空，修一下" |

## 关键环境变量

| 变量 | 默认 | 说明 |
|---|---|---|
| `OPENCLI_DAEMON_PORT` | 19825 | 守护进程端口 |
| `OPENCLI_PROFILE` | — | 多 Chrome profile 时的 alias |
| `OPENCLI_WINDOW` | `command default` | `foreground` / `background` 强制覆盖 |
| `OPENCLI_BROWSER_CONNECT_TIMEOUT` | 30s | 浏览器连接等待 |
| `OPENCLI_BROWSER_COMMAND_TIMEOUT` | 60s | 单条浏览器命令等待 |
| `OPENCLI_CDP_ENDPOINT` | — | 远程浏览器 / Electron 的 CDP 端点 |
| `OPENCLI_CDP_TARGET` | — | 按 URL 子串过滤 CDP 目标 |
| `OPENCLI_VERBOSE` | false | `-v` 也行 |
| `DEBUG_SNAPSHOT` | — | `1` 开启 DOM snapshot 调试输出 |

## 典型场景（脑补）

- **日常**：让 agent 帮你刷一遍 B 站热榜、抓 HackerNews 前 10、查 GitHub 通知
- **跨平台操作**：你不想登录网页版 X，但有 `opencli` 暴露的命令 → agent 能干
- **复用已登录态**：所有需要登录的网站都直接用 Chrome 里的 cookie，省去单独做 OAuth
- **批量操作第三方工具**：把 `gh pr list` 挂进来，让 agent 帮你写 PR 描述

## 我的判断

- ✅ **强项**：把"用 AI 操纵网站"从"自己写 Playwright 脚本"降到"opencli + 一句自然语言"；site 知识持久化很实用
- ⚠️ **弱项**：依赖 Chrome 扩展和守护进程，跨设备/无 GUI 场景用不了；不同网站 adapter 质量参差（这就是为什么有 `opencli-autofix`）
- 💡 **跟 OpenClaw 怎么搭**：装 `opencli-browser` skill，agent 就能借 OpenClaw 的对话上下文 + OpenCLI 的浏览器自动化，去干"读网页 → 决策 → 操作"这种活

## 参考

- 仓库：<https://github.com/jackwener/opencli>
- npm：<https://www.npmjs.com/package/@jackwener/opencli>
- Chrome 扩展：<https://chromewebstore.google.com/detail/opencli/ildkmabpimmkaediidaifkhjpohdnifk>
- 中文 README：<https://github.com/jackwener/opencli/blob/main/README.zh-CN.md>
- Skills 目录：<https://github.com/jackwener/opencli/tree/main/skills>
