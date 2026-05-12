# CLI-Anything 与 OpenCLI

## 是什么

### CLI-Anything（HKUDS）

把任意软件的 CLI 封装成 AI Agent 可用工具链的产品。

- **仓库**：https://github.com/HKUDS/CLI-Anything
- **Hub**：https://clianything.cc（pip install cli-anything-hub）
- **核心概念**：Harness Engineering——为每个软件生成带测试的安全护栏

### OpenCLI

把任意网站 / Electron 应用 / 本地工具变成标准化 CLI 接口。

- **仓库**：https://github.com/jackwener/opencli
- **npm**：`@jackwener/opencli`
- **三大功能**：内置适配器（小红书/知乎/B站等）、Browser 原语操作、CLI Hub 注册

---

## 核心价值

### CLI-Anything

**关键创新**：Harness 带完整测试用例，AI 生成的指令会被验证，不合格则拒绝/修正。

```
软件 CLI → CLI-Anything 封装 → 带测试的 Harness → Claude Code 直接调用
```

### OpenCLI

**关键创新**：复用已登录的浏览器会话，AI 无需 API 就能操作任意网页。

```
登录态浏览器 → OpenCLI browser replay → AI 操作任意网站（小红书/知乎/B站等）
```

---

## 竞品对比

| 维度 | CLI-Anything | OpenCLI |
|------|-------------|---------|
| 目标 | 专业桌面软件 | 任意网站 |
| 方法 | 生成 CLI Harness + 测试 | 浏览器复用 + 适配器 |
| 适配范围 | 有 CLI 的桌面软件 | 任意网站 |
| 测试覆盖 | 每个 Harness 有测试 | 无测试框架 |

---

## 趋势

1. **软件 Agent 化是必然**：所有有 CLI 的专业软件都会有一层 Agent Wrapper
2. **Browser 操作是 Agent 刚需**：没 API 的网站（小红书/B站）靠 Browser replay 解
3. **Harness Engineering 独立成方法论**：从 AGENTS.md 演化，专门解决 AI 操作软件的安全性问题

---

## 来源

- https://github.com/HKUDS/CLI-Anything
- https://github.com/jackwener/opencli
- https://clianything.cc