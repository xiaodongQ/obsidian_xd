# AI Agent 记忆框架深度横评：选型研究报告

> 研究日期：2026-05-15
> 信息来源：GitHub 官方仓库、技术博客、行业横评文章

---

## 一、背景：为什么 Agent 需要记忆框架

AI Agent 每次对话若是从零开始，就只是"高配版计算器"。用户昨天说"我是素食主义者"，今天 Agent 若推荐了红烧肉，就是没有记忆的悲剧。

Agent 记忆分三种类型：

| 类型 | 内容 | 示例 |
|------|------|------|
| **情景记忆** (Episodic) | 具体发生过什么事 | "用户上次说不喜欢辣的" |
| **语义记忆** (Semantic) | 用户是什么人（跨会话持久） | "用户是素食主义者" |
| **程序记忆** (Procedural) | Agent 学到了什么行为规则 | "每次问价格前先问预算" |

---

## 二、六大框架深入解析

### 2.1 Mem0 — 最成熟的生产级选择

**GitHub**: https://github.com/mem0ai/mem0 | ⭐ 4.8万 | 融资 $24M

**定位**：给 Agent 装一个自动去重、三层隔离的智能记忆层

**架构特点**：混合存储（Vector + Graph + KV）

**核心设计**：三层记忆作用域
- `User` 层：用户偏好、历史画像（跨所有会话持久）
- `Session` 层：当前对话上下文（会话级别）
- `Agent` 层：Agent 自身的知识（Agent 私有）

**关键能力**：当新事实与旧记忆冲突时，**自动更新旧记录**而非追加，保持记忆精简不冗余

**v3 算法升级**（2026年最新）：
- 单次提取（single-pass）：一次 LLM 调用完成记忆写入，无 UPDATE/DELETE 循环
- 实体链接（Entity Linking）：跨记忆提取、嵌入并链接实体
- 多信号检索：语义 + BM25 + 实体匹配并行评分融合
- 时序推理（Temporal Reasoning）：时间感知的检索排序

**基准表现**：

| 基准 | v2 | v3 |
|------|----|----|
| LoCoMo | 71.4 | **91.6** |
| LongMemEval | 67.8 | **94.8** |
| BEAM (1M) | — | **64.1** |

**接入方式**：

```python
from mem0 import Memory
m = Memory()

# 存记忆
m.add("我是素食主义者，不吃肉", user_id="alice")

# 取记忆
memories = m.search("用户饮食偏好", user_id="alice")
# [{'memory': '用户是素食主义者，不吃肉', 'score': 0.95}]
```

**安装**：
```bash
pip install mem0ai
# 或托管云：Sign up at app.mem0.ai
```

**适用场景**：个性化推荐 Agent、客服 Agent、需要快速落地的团队

**缺点**：图记忆需要 $249/月 Pro 订阅；无时序建模

---

### 2.2 Zep / Graphiti — 时序推理最强

**GitHub**: https://github.com/getzep/graphiti | ⭐ 5千

**定位**：把每条记忆都打上时间戳和有效期，能推理"这个事实什么时候变了"

**架构特点**：时序知识图谱（Temporal Knowledge Graph）

**核心概念**：
- 每个事实存为知识图谱节点，附带**有效时间窗口**
- 旧事实不删除，只是**失效**——历史完整保留，可追溯"她什么时候改变偏好"

示例：
```
"Kendra 喜欢 Adidas 球鞋"（有效期：2025-01 至 2026-03）
→ 被新事实覆盖 →
"Kendra 喜欢 Nike 球鞋"（有效期：2026-03 至今）
```

**LongMemEval 基准**：**63.8%**（比 Mem0 高约 15 个百分点）

**检索**：P95 延迟约 300ms，语义 + BM25 + 图遍历混合检索，无需额外 LLM 调用

**适用场景**：金融风控 Agent、医疗 Agent、CRM 类需要追踪事实变化的场景

**缺点**：部署复杂度高于 Mem0；社区规模较小

**Zep vs Graphiti 关系**：
- Graphiti = 开源 temporal context graph 引擎
- Zep = 托管服务，基于 Graphiti，提供商业化 governance 和 SLA

---

### 2.3 Letta / MemGPT — OS 级记忆管理

**GitHub**: https://github.com/letta-ai/letta | ⭐ 3.6万

**定位**：把操作系统的分层内存管理思路搬到 Agent 上

**架构特点**：分层内存（OS-Inspired Tiered Memory）

| 层级 | 类比 | 内容 | 特点 |
|------|------|------|------|
| Core Memory | 内存 RAM | 当前对话核心信息 | 始终在 context 窗口内 |
| Recall Memory | 缓存 Cache | 近期对话历史 | 按需检索 |
| Archival Memory | 硬盘 HDD | 长期知识存储 | 无限扩展 |

**最大差异化**：Agent **自己主动调用工具**来管理记忆，而非框架后台默默做：
- `core_memory_replace()` — 修改核心记忆
- `archival_memory_search()` — 搜索归档知识
- `archival_memory_insert()` — 写入长期记忆

**原生支持多 Agent 协作**：多个 Agent 可以共享同一个记忆池

**适用场景**：需要长期自我进化的 Agent、研究型 Agent、需要多 Agent 协作的复杂系统

**缺点**：上手成本高；需要部署 Letta Server

**接入方式**：
```bash
npm install -g @letta-ai/letta-code  # CLI
# 或
pip install letta-client              # Python SDK
```

---

### 2.4 A-MEM — 卡片笔记法驱动

**GitHub**: https://github.com/agiresearch/A-mem | 论文：arXiv 2502.12110 | 被引 412 次

**定位**：用"卡片笔记法（Zettelkasten）"组织 AI 记忆，让记忆之间**自动建立关联网络**

**灵感来源**：德国社会学家卢曼的卡片笔记法——每条记忆是一张"知识卡片"，卡片之间自动建立关联链接

**当 Agent 获得新记忆时，A-MEM 做三件事**：
1. **构建笔记**：提取关键概念、上下文、标签
2. **动态链接**：分析与已有记忆的关联，自动建立索引链接
3. **进化更新**：已有记忆根据新信息动态更新，不是简单追加

**架构**：ChromaDB 向量存储 + LLM 后端

```python
from agentic_memory.memory_system import AgenticMemorySystem

memory = AgenticMemorySystem(
    model_name='all-MiniLM-L6-v2',
    llm_backend="openai",
    llm_model="gpt-4o-mini"
)

memory.add_note("用户喜欢科幻小说，最近在读三体")
results = memory.search_agentic("用户阅读偏好", k=5)
```

**适用场景**：知识密集型 Agent、学术研究助手、需要复杂推理关联的场景

**缺点**：工程化程度不如 Mem0/Letta；生产案例较少

---

### 2.5 MemOS — 系统级三态记忆调度

**GitHub**: https://github.com/MemTensor/MemOS | 论文：arXiv 2507.03724

**定位**：把"记忆"当成操作系统资源来统一调度，不只是记忆框架，更是 Memory OS

**架构特点**：三态记忆统一调度（MemCube）

| 记忆类型 | 实现形式 | 类比 |
|------|------|------|
| **激活记忆** | KV-Cache | CPU 寄存器 |
| **文本记忆** | 向量数据库/文档 | 内存 RAM |
| **参数记忆** | LoRA 权重微调 | 硬盘固化知识 |

**三态可以互相转化**：
- 高频访问的文本记忆 → 自动转为 KV-Cache（激活记忆）加速访问
- 持续活跃的激活记忆 → 可调度为参数记忆永久固化

**调度器**（MemScheduler）根据访问频率、重要性、时效性自动管理三态之间的迁移

**v2.0 Stardust（2025-12）新增能力**：
- Knowledge Base 支持（文档/URL 解析 + 跨项目共享）
- 记忆反馈与精确删除
- 多模态记忆（图片/图表）
- Tool memory
- MemOS OpenClaw 插件（本地 + 云端）

**适用场景**：做底层 LLM 系统的团队、研究记忆机制的学者、有定制化需求的大型 Agent 平台

**缺点**：工程成熟度最低，仍处于研究阶段

---

### 2.6 TencentDB Agent Memory（腾讯龙宫记忆）— 渐进式四层管道

**GitHub**: https://github.com/Tencent/TencentDB-Agent-Memory | ⭐ 1.4k | **MIT** | 2026-05 发布

**定位**：将完整信息卸载到外部存储，保留任务执行过程中的关键状态与结构关系

**核心能力**：

#### 1. Mermaid 任务画布
系统将 Agent 的任务过程组织成**结构化任务图**，保留任务状态、步骤摘要和执行关系。即使上下文中只保留一张轻量级任务画布，Agent 依然能快速判断当前任务进度及步骤依赖。

#### 2. 上下文卸载（Context Offloading）
工具调用完成后，网页内容、日志、中间结果等原始信息不继续占用上下文窗口，而是转移到外部文件系统保存；上下文中仅保留摘要和索引，需要时按需恢复。

**四层渐进式管道**：

| 层级 | 内容 | 说明 |
|------|------|------|
| L0 | 对话录制 | 自动捕获每轮对话原始消息，IMemoryStore + JSONL 双写 |
| L1 | 记忆提取 | LLM 从对话中提取结构化记忆，支持向量去重与冲突检测 |
| L2 | 上下文压缩 | 工具结果、网页内容等原始信息卸载，仅保留摘要 |
| L3 | 用户画像 | 跨对话自动形成用户偏好和历史背景（PersonaMem） |

**实测数据**：

| 场景 | Token 消耗降低 | 效果提升 |
|------|------|------|
| 网页搜索 | 最高 **61%** | 成功率 +52% |
| 代码修复 | 最高 **33%** | 完成率 +10% |
| 长文档处理 | 最高 **31%** | 准确率 +8% |
| PersonaMem 画像理解 | — | 48% → **76%** |

**支持框架**：OpenClaw、Hermes（主流 Agent 框架一键部署）

**安装**：
```bash
openclaw plugins install @tencentdb-agent-memory/memory-tencentdb
```

**数据存储**：以普通文件保存（JSONL），直接查看和调试，无需额外数据库

---

### 2.7 OpenViking（字节跳动）— 文件系统范式

**定位**：把 memory 当文件系统管理，专为 AI Agent 设计的上下文数据库

**核心思路**：采用 `viking://` 协议统一管理 Agent 所有上下文，类似文件系统路径

**URI 结构**：
```
viking://
├── resources/{project}/     # 资源：项目文档、代码仓库
│   ├── .abstract.md         # L0 摘要（~100 tokens）
│   ├── .overview.md         # L1 概览（~2k tokens）
│   └── {files...}           # L2 详情（完整内容）
├── user/{user_space}/       # 用户数据
│   └── memories/
├── agent/{agent_space}/     # Agent 数据
│   └── skills/              # 技能定义
```

**三层上下文结构**：L0/L1/L2 按需加载，渐进式加载显著降低 Token 消耗

**核心痛点解决**：

| 痛点 | 解决方案 |
|------|------|
| 上下文碎片化 | 文件系统范式统一管理 |
| Token 消耗激增 | 三层上下文按需加载 |
| 检索效果差 | 目录递归检索（先定位目录，再语义精检） |
| 上下文不可观测 | 可视化检索轨迹 |
| 记忆无法迭代 | 自动会话管理，提取长期记忆 |

**安装**：
```bash
pip install openviking

import openviking as ov
client = ov.OpenViking(path="./data")
client.initialize()
client.add_resource("./my-project")
client.wait_processed()
context = client.find("帮我分析这个项目的架构")
```

---

## 三、综合横向对比

| 框架 | GitHub Stars | 架构类型 | 时序推理 | 多 Agent | 生产成熟度 | 上手难度 |
|------|------|------|------|------|------|------|
| **Mem0** | 4.8万⭐ | 混合向量+图+KV | ❌ | 部分 | ⭐⭐⭐⭐⭐ | 低 |
| **Zep/Graphiti** | 5千⭐ | 时序知识图谱 | ✅ 最强 | 部分 | ⭐⭐⭐⭐ | 中 |
| **Letta/MemGPT** | 3.6万⭐ | OS 分层内存 | 部分 | ✅ 原生 | ⭐⭐⭐⭐ | 高 |
| **A-MEM** | 研究级 | Zettelkasten 网络 | 部分 | ❌ | ⭐⭐ | 中 |
| **MemOS** | 新兴 | 三态统一调度 | 部分 | 部分 | ⭐ | 极高 |
| **TencentDB Agent Memory** | 1.4k⭐ | 四层渐进管道 | ✅ | 部分 | ⭐⭐⭐⭐ | 低 |
| **OpenViking** | — | 文件系统范式 | ✅ | ✅ | ⭐⭐⭐ | 低 |

---

## 四、场景化选型建议

### 快速上线 → Mem0
API 3 行代码接入，有托管云服务，社区最大，文档最全，适合有个性化推荐/客服需求的团队

### 金融/医疗/法律（时序事实追踪）→ Zep / Graphiti
时序知识图谱是唯一正解，63.8% LongMemEval 领先不是白来的，适合需要追踪"用户什么时候改变偏好"的场景

### 长期自我进化 + 多 Agent 协作 → Letta
OS 级记忆调度 + 原生多 Agent 协作，适合有工程能力、要做复杂 Agent 系统的团队

### 研究型 / 学术场景 → A-MEM
NeurIPS 2025 论文级算法，关联推理能力最强，但生产案例少，适合实验性质的项目

### LLM 底层系统定制 → MemOS
三态记忆调度是未来方向，现在跟进研究积累先发优势，工程化程度最低

### 长任务 Token 成本控制 → TencentDB Agent Memory
上下文卸载 + Mermaid 任务画布是独特能力，Token 最高降 61%，已产品化对接 OpenClaw/Hermes

### 复杂上下文组织 + 上下文可观测 → OpenViking
文件系统范式天然直观，适合代码助手、企业知识库等需要强结构化上下文管理的场景

---

## 五、组合落地建议

| 目标 | 推荐组合 |
|------|------|
| **一周快速上线** | Mem0 托管云 + OpenAI API |
| **高精度时序场景** | Zep + 自建 Neo4j |
| **长期复杂系统** | Letta Server + PostgreSQL |
| **Token 成本敏感** | TencentDB Agent Memory + OpenClaw |
| **强上下文结构化** | OpenViking + 向量数据库 |

---

## 六、关键洞察

1. **记忆不是"有就行"**：错误记忆比无记忆更危险——医疗 Agent 记错药物禁忌，金融 Agent 记错用户风险偏好，都是灾难

2. **时序推理是大势**：Graphiti 和 TencentDB Agent Memory 都在时序方向发力，Mem0 v3 也引入了 Temporal Reasoning

3. **上下文卸载是新思路**：TencentDB 和 OpenViking 都引入了"分层加载 + 按需恢复"机制，本质是把 Agent 上下文当操作系统虚拟内存来管理

4. **开源不等于可用**：MemOS、A-MEM 等框架算法领先但工程化程度低，生产落地需要较多二次开发

5. **腾讯入场值得关注**：TencentDB Agent Memory 2026-05 才发布，GitHub Stars 1.4k 增长很快，且已集成 OpenClaw 插件体系，结合"龙虾"记忆服务产品化

---

## 七、参考链接

- Mem0: https://github.com/mem0ai/mem0
- Graphiti: https://github.com/getzep/graphiti
- Letta: https://github.com/letta-ai/letta
- A-MEM: https://github.com/agiresearch/A-mem
- MemOS: https://github.com/MemTensor/MemOS
- TencentDB Agent Memory: https://github.com/Tencent/TencentDB-Agent-Memory
- 腾讯龙宫记忆（量子位报道）: https://www.qbitai.com/2026/05/417753.html
- OpenViking 深度解析: https://github.com/ForceInjection/AI-fundermentals/blob/main/08_agentic_system/context/openviking-deep-dive.md
- LongMemEval 基准论文: arXiv 2501.13956
- MemOS 论文: arXiv 2507.03724
- A-MEM 论文: arXiv 2502.12110

---

*本笔记由 AI 辅助整理，信息来源为公开 GitHub 仓库和技术博客，内容如有疏漏请以官方最新版本为准。*