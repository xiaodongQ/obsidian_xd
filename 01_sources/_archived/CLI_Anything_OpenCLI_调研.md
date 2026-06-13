---
title: "CLI Anything / OpenCLI 调研"
tags: ['CLI', 'OpenCLI', 'Harness']
date: 2026-05-09
---

# CLI Anything / OpenCLI 调研

> 调研时间：2026-05-13
> 调研方法：纵横分析法（时间线 / 竞品 / 价值链 / 趋势）

---

## 一、是什么

### CLI-Anything（HKUDS/CLI-Anything）

**一句话**：把任意软件的 CLI 封装成 AI Agent 可用的工具链。

来自香港大学团队（HKUDS），核心思想是 **Harness Engineering**——为每个软件生成一个"安全护栏"（Harness），让 AI 在里面执行操作，不会失控。

- 仓库：https://github.com/HKUDS/CLI-Anything
- 社区 Hub：https://clianything.cc（pip install cli-anything-hub 后 cli-hub install <name>）
- Claude Code 插件：`cli-anything-plugin/`，直接加载进 Claude Code 使用

**已生成的 Harness 列表**（部分）：
| 软件 | 测试数 | 类型 |
|------|--------|------|
| Blender | 208 tests | 3D 建模 |
| GIMP | 107 tests | 图片编辑 |
| Inkscape | 202 tests | 矢量绘图 |
| Audacity | 161 tests | 音频编辑 |
| OBS Studio | 153 tests | 录屏直播 |
| Kdenlive | 155 tests | 视频剪辑 |
| Draw.io | 138 tests | 图表绘制 |
| LibreOffice | 158 tests | 办公套件 |
| ComfyUI | 70 tests | AI 图像生成 |
| Godot | — | 游戏引擎 |
| Ollama | 98 tests | 本地 LLM |

### OpenCLI（jackwener/OpenCLI）

**一句话**：把任意网站 / Electron 应用 / 本地工具变成标准化 CLI 接口。

- 仓库：https://github.com/jackwener/opencli
- npm 包：`@jackwener/opencli`
- 内置适配器（部分）：Bilibili、知乎、小红书、Reddit、HackerNews、Twitter/X

**三大功能**：
1. **内置适配器**：直接用 CLI 操作主流网站（B站弹幕、知乎、小红书等）
2. **Browser 原语**：复用已登录的浏览器会话，让 AI agent 操作任意网页（点击、填表、提取）
3. **CLI Hub**：注册本地 CLI 工具（gh、docker 等），AI agent 可以统一发现和调用

---

## 二、竞品对比

| 维度 | CLI-Anything | OpenCLI |
|------|-------------|---------|
| **目标** | 软件 CLI → Agent 可用 | 网站 / 浏览器 → Agent 可用 |
| **核心方法** | 生成带测试的 CLI Harness | 浏览器复用 + 适配器 |
| **典型用户** | 需要操作专业软件（Blender/GIMP等）的 AI | 需要操作网页、自动化的 AI |
| **上手方式** | Claude Code 插件 | npm 安装 |
| **适配范围** | 有 CLI 的桌面软件 | 任意网站 |
| **社区** | clianything.cc Hub | 内置 + 自定义适配器 |
| **测试覆盖** | 每个 Harness 有完整测试 | 无测试框架 |

**相关工具**：
- AutoCLI.ai — 把网站转成 CLI 输出（结构化抓取）
- Firecrawl — 为 AI Agent 提供实时网页数据访问

---

## 三、价值链分析

### CLI-Anything 价值链

```
软件原有 CLI（Blender --help）
        ↓ [CLI-Anything 封装]
带测试的 Harness（Blender Harness + 208 tests）
        ↓
Claude Code / AI Agent 直接调用（"帮我把立方体改成球形"）
        ↓
用户获得"对着 Blender 说话就能干活"的能力
```

**关键创新**：Harness 不是简单包装，而是带测试用例——这意味着 AI 生成的指令会被 Harness 验证，不合格则自动拒绝或修正。

### OpenCLI 价值链

```
已登录的浏览器会话（你有 B 站登录状态）
        ↓ [OpenCLI 复用]
AI Agent 通过 browser 原语操作（点击、填表、提取）
        ↓
"帮我把 B 站收藏夹导出成 CSV"
        ↓
无 API 的网站也能被 AI 操作
```

**关键创新**：不需要网站提供 API，直接复用你的登录态，AI 替你操作网页。

---

## 四、趋势判断

### CLI-Anything 趋势

1. **软件 Agent 化的基础设施**：未来所有有 CLI 的专业软件都会有一层 Agent Wrapper，CLI-Anything 是目前最系统的方案
2. **社区 Hub 是关键**：clianything.cc 的模式——社区贡献 Harness，质量靠测试保证——是可持续的开源路径
3. **Harness Engineering 独立成方法论**：从 Claude Code 的 AGENTS.md 演化而来，专门解决"AI 操作软件安全性"问题

### OpenCLI 趋势

1. **浏览器操作是 Agent 的刚需**：很多网站没有 API，OpenCLI 的 browser replay 模式是少数解法之一
2. **CLI Hub 概念值钱**：把本地所有 CLI 工具注册进 AI 可发现的统一接口——这个 Hub 模式会成为 Agent 工具生态的基础设施
3. **和 MCP 有竞争也有互补**：MCP 是协议层，OpenCLI 是实现层，两者解决不同层次的问题

---

## 五、结论

### CLI-Anything ✅ 有价值
- 适合需要操作**专业桌面软件**（Blender/GIMP/Godot）的场景
- 已有的完整测试 Harness 是护栏，不会让 AI 乱改文件
- 社区 Hub 模式可持续

### OpenCLI ✅ 有价值
- 适合需要操作**网页 / 已有登录态**的场景
- B 站、知乎、小红书这类没有 API 的平台尤其有用
- CLI Hub 的思路值得借鉴——让 AI 统一发现本地工具

### 两者关系
**不竞争，是互补的两层**：
- OpenCLI = 操作层（网站、浏览器）
- CLI-Anything = 应用层（专业软件）