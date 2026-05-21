---
title: 别让模型烧Token了！GitHub 20k星神作：把全网变成命令行
tags: [文章, AI Coding, OpenCLI, Token省流, Agent工具, 量子位]
created: 2026-05-21
source: https://mp.weixin.qq.com/s/QvvriYIJrulyLMb0xHfWvQ
source_alias: 量子位-凹非寺
published: 2026-05-16
---

# 别让模型烧Token了！GitHub 20k星神作：把全网变成命令行

## 基本信息

| 项目 | 内容 |
|------|------|
| 作者 | 闻乐（量子位） |
| 来源 | 量子位公众号 |
| 发布日期 | 2026-05-16 |
| 标签 | AI Coding / OpenCLI / Token省流 / Agent工具 |
| 原始链接 | https://mp.weixin.qq.com/s/QvvriYIJrulyLMb0xHfWvQ |
| 相关项目 | https://github.com/jackwener/OpenCLI |

## 核心观点

### OpenCLI 是什么

GitHub 20k+ 星的开源项目，将**任意网站变成命令行工具**。通过本地 CLI 直接操控浏览器，数据返回结构化，全程**零 Token 推理消耗**。

> 传统 Agent "边看边点" → OpenCLI 命令在本地浏览器执行，不经过大模型推理，**运行时不花一分钱 Token**

### 核心能力

**支持的平台（100+ 站点适配器）：**

| 类别 | 平台 |
|------|------|
| 国内社交 | 小红书、B站、知乎、豆瓣、虎扑、贴吧 |
| 海外社交 | Twitter/X、HackerNews、Pixiv |
| 办公套件 | 飞书（200+ 命令）、企业微信、钉钉 |
| 通讯录 | 微信、Telegram、Discord |

**主要功能：**
- `opencli zhihu search "AI Agent"` — 站内搜索
- `opencli zhihu download --url "文章地址" --output ./zhihu` — 下载文章（图文/视频/音频，导出 Markdown/CSV/JSON）
- 批量爬取数据、创作者数据分析、评论区抓取
- 翻页、表单填写、页面点击

**办公场景：**
- 飞书：`opencli lark-cli` — 消息/文档/日历/任务
- 企业微信：`opencli wecom-cli`
- 钉钉：`opencli dws`

### 技术架构

**关键创新**：`CLI 命令在本地浏览器里直接执行，不经过大模型推理`

| 对比维度 | 大模型操作浏览器 | OpenCLI 本地执行 |
|----------|-----------------|-----------------|
| Token 消耗 | 高（每次页面操作都烧 Token） | **零**（本地确定性命令） |
| 结果一致性 | 每次输出结构可能不同 | **结构一致，可管道、可脚本、CI/CD友好** |
| 速度 | 慢（大模型推理延迟） | 快（确定性本地执行） |

### AI Agent 集成

OpenCLI 提供 **`opencli-adapter-author` Skill**：
```bash
npx skills add jackwener/opencli --skill opencli-adapter-author
```

Agent 就能自动写适配器（通过 npx 触发），社区还有插件系统可一键安装别人写好的适配器。

**已支持的 AI 工具：**
- Cursor Composer / 聊天 / 代码提取
- ChatGPT macOS 桌面端自动化
- Notion（搜索/读取/写入）
- OpenAI Codex CLI 无头驱动
- Discord 桌面端（消息/频道/服务器操作）

## 相关页面

- [[Claude_Code]] — Claude Code 相关技能
- [[Agent_Skill设计模式.md]] — Skill 设计模式
- [[Harness_Engineering]] — Harness Engineering 核心思想