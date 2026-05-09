# 一个文件让 AI Coding 效率翻倍：AGENTS.md 实践指南

> 来源：https://view.inews.qq.com/k/20260506A0271500
> 作者：岛风（阿里云开发者）
> 标签：AGENTS.md, AI Coding, Codex, Claude Code, 最佳实践

## 核心定义

**AGENTS.md**：在代码仓库根目录放置一个 Markdown 文件，告诉 AI 工具项目是什么、怎么构建、有什么规矩。可以理解为给 AI 看的 README——README.md 是给人类看的项目说明，AGENTS.md 是给 AI Agent 看的项目指令。

## 为什么有效

| 特性 | 说明 |
|------|------|
| **No decision point** | 信息从一开始就在上下文中，Agent 不需要选择是否加载 |
| **Consistent availability** | 始终可用，不像 Skills 需要异步加载 |
| **Faster to iterate** | 修改 Markdown 文件比重新部署 Skill 配置快得多 |

## 最佳实践

### 1. 渐进式披露

最好的 AGENTS.md 通常不长，主文件约 **100-150 行**，外加少量聚焦引用文档。
- 研究：这种结构在 ~100 个核心文件规模的模块里能稳定带来 10-15% 整体提升
- 主文件继续膨胀时，收益开始反转

### 2. 流程化步骤

研究显示，流程化步骤（Step-by-step guides）对 Agent 帮助非常大：
- 缺少 wiring 文件的 PR 比例从 40% 降到 10%
- `correctness` 提升 25%
- `completeness` 提升 20%

### 3. 决策表消除歧义

决策表把"模糊偏好"改写成"显式路由规则"。例如"选 React Query 还是 Zustand"可以通过决策表说明。

### 4. 少量真实代码示例

3-10 行的真实生产代码片段，比抽象原则更能帮助 Agent 复用现有模式。

### 5. 每个"不要"配一个"应该怎么做"

### 6. 文档边界与代码边界一致

### 7. 每个规则都要回答：Agent 下一步该做什么

## 具体配置建议

### 工具优先级

```markdown
## Tool Priority
- Filename search: `fd`
- Text/content search: `rg` (ripgrep)
- AST/structural search: `sg` (ast-grep)
```

### 搜索卫生规范

```markdown
### Search Hygiene (fd/rg/sg)
- Exclude bulky folders: `.git`, `node_modules`, `coverage`, `out`, `dist`
- Prefer running searches against a scoped path (e.g., `src`)
```

### Lint 检查闭环

```markdown
## Commands
- `make lint` - 运行所有 lint 检查
- `make test` - 运行测试
- `make verify` - 完整验证（lint + test）
```

## 与 Harness Engineering 的关系

AGENTS.md + 文档体系 + lint 脚本 + 启动脚本 + 验证规范，本质上是在构建一个**反馈回路**：
- AI 读 AGENTS.md 理解项目 → 写代码 → 自动检查 → 启动验证 → 根据结果修正
- 人类的角色是**设计这个回路**，而不是在回路中的每一步都亲自操作

## 迭代方法

1. **Start minimal**: 6-10 条规则，3-5 个命令引用
2. **Use agents**: 在真实任务上工作 1-2 天
3. **Note failures**: Agent 哪些地方做错了
4. **Add rules**: 把修复写入 AGENTS.md
5. **Prune**: 删除 Agent 总是正确遵循的规则
6. **Repeat**

## 与 Skills 的对比

| 场景 | 推荐 |
|------|------|
| 基本约定和约束 | AGENTS.md 更好 |
| 需要编排的复杂工作流（多步部署、复杂测试套件） | Skills 更合适 |

Skills 的问题：调用时机不对、措辞变化结果就不同、Agent 忘了调用、可能没意识到自己需要帮助。

## 常见误区

- ❌ 把所有注意事项都写入 AGENTS.md
- ❌ 认为装了 Skill AI 编程能力就会自动提升
- ✅ 让 AI 在不同场景下主动选择适合的工具
- ✅ 把关键知识写进 AGENTS.md 进行强调
