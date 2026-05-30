---
title: "斩获29k+ Star！Claude 最强画图外挂来了，比Visio快10倍！"
author: "macrozheng"
source: "博客园/macrozheng"
date: 2026-05-28
url: "https://mp.weixin.qq.com/s/ck56FuDY85bezAzYogGx6g"
tags: ["Claude Code", "Draw.io", "MCP", "AI画图", "工具推荐"]
category: "AI工具"
description: "Claude Code 通过 Next AI Draw.io MCP 驱动 Visio 替代方案，自然语言命令绘制流程图/架构图，效率比 Visio 快 10 倍，GitHub 斩获 29k+ stars。"
---

# 斩获29k+ Star！Claude 最强画图外挂来了，比Visio快10倍！

## 核心功能

- **Claude Code + Draw.io MCP**：通过 MCP 协议连接 Draw.io，Claude 可直接生成 `.drawio` 格式的可编辑图表
- **自然语言驱动**：只需描述需求，AI 自动生成流程图、架构图、时序图、ER 图等
- **支持多种图表类型**：流程图、思维导图、架构图、UML 类图、ER 图、Mermaid 等
- **与 Claude Code / Cursor / VS Code 无缝集成**：通过 MCP 协议直接调用

## 安装方式

```bash
# 添加 MCP server
claude mcp add drawio -- npx @drawio-mcp/server

# 或在 Claude Code 中通过指令直接使用
```

## 典型使用场景

| 场景 | 描述 |
|------|------|
| 系统架构图 | 描述微服务架构，生成可直接编辑的 Draw.io 图 |
| 流程图 | 描述业务流程，自动生成标准流程图 |
| 技术文档 | 生成 API 架构、数据流图等 |
| 技术分享 | 用自然语言生成高颜值技术图 |

## 29k+ stars 来源

项目 GitHub：[DayuanJiang/next-ai-draw-io](https://github.com/DayuanJiang/next-ai-draw-io)（VS Code 扩展 + MCP 支持），配合 jgraph/drawio-mcp 使用效果最佳。