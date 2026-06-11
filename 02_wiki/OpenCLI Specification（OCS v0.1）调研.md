---
title: OpenCLI Specification（OCS v0.1）调研
date: 2026-06-11
tags: [调研, CLI, 规范, OpenAPI, MCP, TypeSpec]
source: https://github.com/spectreconsole/open-cli
spec_version: 0.1
status: proposal/draft
---

# OpenCLI Specification（OCS v0.1）调研

> 📅 2026-06-11 调研
>
> ⚠️ 名字撞车提醒：另有一个 [[OpenCLI（jackwener-opencli）调研]]（工程化项目，把网站/本地 CLI 转成统一 CLI）。本笔记说的是**规范**本身。

## 一句话定位

**OpenAPI 之于 HTTP API，就是 OpenCLI 之于 CLI**。

OpenCLI Specification（OCS）是一份平台无关、语言无关的 CLI 接口描述规范。用一份 JSON / YAML 文档声明 CLI 的命令树、参数、选项、退出码 —— 人类和机器都能在不读源码、不查 man 的情况下，知道该工具怎么调。

## 为什么需要

| 痛点 | 现状 | OpenCLI 带来的 |
|---|---|---|
| 文档与实际不一致 | `--help` 和官网分两份维护 | 单一描述文件做 single source of truth |
| 自动补全脚本重复造 | bash/zsh/fish/pwsh 各写一份 | 一份描述生成多 shell 补全 |
| AI / MCP 调用 CLI 困难 | LLM 反复试 `--help` | 直接读结构化描述转 MCP tool schema |
| API 变更难追踪 | 选项被改名没人通知 | 描述文件做 diff 自动告警破坏性变更 |
| 跨语言客户端 | Python 包 Go CLI 要手写 wrapper | 描述生成强类型 client |

## 规范结构

```
OpenCLI Document
├── opencli      : string      # 规范版本号，如 "0.1"
├── info         : CliInfo     # 工具元信息
├── command      : Command     # 根命令（递归）
└── conventions  : Conventions # 语法约定
```

- 字段 camelCase，大小写敏感
- 数组顺序有规范意义（生成器按声明顺序展示）

## 核心对象

### CliInfo
| 字段 | 必填 | 说明 |
|---|---|---|
| title | ✓ | 应用标题 |
| version | ✓ | 应用版本 |
| summary | ✗ | 一句话简介 |
| description | ✗ | 详细描述 |
| contact | ✗ | 联系人/组织 |
| license | ✗ | 许可证（支持 SPDX） |

### Command（递归核心）
| 字段 | 默认 | 说明 |
|---|---|---|
| name | 必填 | 命令名 |
| aliases | — | 别名 |
| description | — | 描述 |
| options | — | 该命令选项 |
| arguments | — | 位置参数 |
| commands | — | 子命令（递归） |
| exitCodes | — | 退出码 |
| examples | — | 使用示例 |
| interactive | false | 是否需 TTY |
| hidden | false | 是否隐藏 |
| metadata | — | 扩展元数据 |

### Option
- `aliases` 短别名；`required` 必填；`recursive: true` 全局 flag（**子命令继承**）；`group` 帮助分类

### Argument
- `arity: { minimum, maximum }` 接受值数量范围
- `maximum: null` 表示 vararg（变长）

### Arity 默认
- `{ minimum: 1, maximum: 1 }`（自 2026-03-24 起）

### ExitCode
- `code: int` + `description: string`

### Conventions
- `groupOptions: true` —— 是否允许短选项合并（`-rf`）
- `optionArgumentSeparator: " "` —— 选项与值分隔符（也支持 `=`）

### Metadata
- `{ name, value }` 键值对，写规范没覆盖的扩展（如 MCP 工具名、权限分级）

## 最小示例：greet

```json
{
  "$schema": "https://opencli.org/draft.json",
  "opencli": "0.1",
  "info": { "title": "greet", "version": "1.0.0", "summary": "A friendly greeter", "license": { "identifier": "MIT" } },
  "command": {
    "name": "greet",
    "options": [
      { "name": "--name", "aliases": ["-n"], "required": true,
        "arguments": [{ "name": "NAME", "required": true }] },
      { "name": "--shout" }
    ],
    "exitCodes": [
      { "code": 0, "description": "Success" },
      { "code": 1, "description": "Missing name" }
    ],
    "examples": ["greet --name Alice", "greet -n Bob --shout"]
  }
}
```

## 全局 flag（recursive）

`--namespace` / `--kubeconfig` 在 kubectl 整棵命令树都生效 → 根命令声明一次即可：

```json
{ "name": "--namespace", "aliases": ["-n"], "recursive": true,
  "arguments": [{ "name": "NS", "required": true }] }
```

## 交互式命令

```json
{ "name": "login", "interactive": true }
```

消费者（MCP server / CI）看到这个就知道必须 TTY，不能非交互调用。

## 五大落地场景

### 1. 多 shell 补全脚本生成
一份 `mytool.opencli.json` → 喂给生成器 → 产出 bash/zsh/fish/powershell 补全。

### 2. Markdown / HTML 文档生成
避免 README 与 `--help` 漂移；递归 `Command.commands` 渲染成多级标题 + 表格。

### 3. 转 MCP tool，AI 直接调
核心目标场景。把每个叶子命令注册成 MCP tool：
```ts
// 伪代码：OpenCLI 描述 → MCP tool
return {
  name: [rootBin, ...path, cmd.name].join("_"),
  description: cmd.description,
  inputSchema: { type: "object", properties, required },
  handler: async (input) => runProcess(rootBin, [...path, cmd.name, ...buildArgs(input)])
};
```
**效果**：kubectl、gh、docker 都备好 OCS 描述后，AI Agent 零定制成本调用。

### 4. CLI API 变更检测
```bash
opencli-diff dotnet@8.0.json dotnet@9.0.json
# [BREAKING] option --no-restore renamed to --skip-restore
# [ADDED] workload subcommand
# [CHANGED] --configuration acceptedValues: ReleaseAOT 新增
```

### 5. 跨语言客户端代码生成
类似 OpenAPI Generator，可生成 Python/Go/Java 强类型 wrapper。

## 与 OpenAPI 对照

| 维度 | OpenAPI | OpenCLI |
|---|---|---|
| 描述对象 | HTTP API | CLI 应用 |
| 核心 | Path / Operation | Command（递归） |
| 输入 | Parameters / RequestBody | Options / Arguments |
| 输出 | Responses（状态码） | ExitCodes（退出码） |
| 元信息 | info 块 | info 块（结构几乎一致） |
| 版本号 | `openapi: 3.1.0` | `opencli: 0.1` |
| 扩展机制 | `x-*` 字段 | `metadata: [{name, value}]` |
| 工具生态 | Swagger UI、Redoc、Generator | **建设中** |

**CLI 特有概念**（OpenAPI 没有）：
- 递归命令树（OpenAPI 是扁平 path）
- `arity`（选项可接受 N 个值）
- `interactive`（需要 TTY）
- `conventions`（短选项合并、分隔符）
- `recursive`（全局 flag）

## 现状

- 规范版本：**v0.1**（明确标注 proposal，欢迎社区反馈）
- 维护方：Spectre.Console 组织（Patrik Svensson 等）
- 仓库：<https://github.com/spectreconsole/open-cli>
- 站点：<https://opencli.org>（Docusaurus）
- 工具链：基于 [TypeSpec](https://typespec.io) 维护规范源 → 自动生成 JSON Schema；构建用 Cake / .NET 9 SDK
- 仓库内含：规范文档（`draft.md`）、JSON Schema（`schema.json`）、TypeSpec 定义（`typespec/main.tsp`）、dotnet 示例（`examples/dotnet.json`）

## 最近变更（节选）

| 日期 | 变更 |
|---|---|
| 2026-04-19 | 根命令也成 Command Object 实例（统一模型） |
| 2026-03-24 | arity 默认改为 `{minimum: 1, maximum: 1}` |
| 2025-10-04 | schema 增加默认值 |
| 2025-08-06 | Option 新增 `recursive` 字段；Argument 移除 `ordinal` |
| 2025-07-15 | 新增 `int`（截断） |

## 我的判断

- ✅ **强项**：把 CLI 工具从"野生格式"统一到结构化描述 → 文档、补全、MCP、客户端生成全打通。OpenAPI 已证明这条路走得通，CLI 复制很合理。
- ⚠️ **弱项**：v0.1 草案、生态尚在早期；要等头部 CLI 工具（gh、docker、kubectl）官方支持才有规模效应。
- 💡 **对个人**：现在主要价值是**给自家小工具写一份 OCS 描述**，马上能享受到"文档自动生成 + 多 shell 补全 + MCP 暴露"三件套。
- 💡 **与 OpenAPI 协同**：HTTP API 已经有 OpenAPI；CLI 也有 OCS 后，AI Agent 调一套系统就不用再问"先查 man 还是先看 Swagger"。

## 参考

- 仓库：<https://github.com/spectreconsole/open-cli>
- 站点：<https://opencli.org>
- 深度调研（中文，2026-05-19）：<https://www.cnblogs.com/cwp0/p/20080251>
- TypeSpec：<https://typespec.io>
- Spectre.Console 组织：<https://github.com/spectreconsole>
