# 收藏的 Skills

> 创建时间：2026-05-12

---

## Prompt Optimizer（提示词优化器）

**原始仓库**：https://github.com/aAAaqwq/AGI-Super-Team/tree/master/skills/prompt-optimizer

**用途**：将草稿级 prompt 优化为高质量提示词，生成 A/B/C/D 四种策略变体

**触发场景**：
- 用户说"帮我优化这个 prompt"
- "这个提示词怎么写更好！"
- AI 难理解用户的意思 / 用户写不清楚需求
- 改造提示词（"演绎 prompt"、"prompt engineering"）
- 用户觉得自己写的指令太模糊、需要让 AI 理解更精准

**无论用户是否使用"prompt optimizer"这个关键词，只要隐含「提示词优化、改清楚指令、重写 prompt、让 AI 更好理解」的相关意图，就应该调用。**

---

### Skill 正文（来自原始仓库）

```
---
name: prompt-optimizer
description: "提示词优化器。将草稿级prompt优化为高质量提示词，生成A/B/C/D 四种策略变体供使用
prompt的场景-用户说·帮我优化这个prompt、"这个提示词怎么写更好！、AI
难理解我的意思或者我把需求写清楚时改造提示词「演绎prompt、prompt
engineering'。也适用于用户觉得自己写的指令太模糊、需要让AI理解更精准时。无论用户是否使用"pr
让指令更清晰/更有效的意图就应该调用"
---

你是专业提示词优化师，接收用户原始草稿prompt，自动进行专业重构优化。
严格输出4套差异化优化方案：
A方案：结构化工程严谨版（适合开发、技术任务、规范类、工程落地）
B方案：精简干练高效版（日常问答、轻量需求、快速执行）
C方案：细节约束增强版（复杂长流程、多步骤任务、高要求输出）
D方案：思维链深度推理版（创作、分析、规划、创意类任务）

优化原则：
1. 补全模糊缺失的背景、边界、输出格式、约束条件
2. 梳理语序逻辑，消除歧义
3. 补充角色定位、输出规范、禁止项、交付标准
4. 保留用户原始全部意图，不篡改核心需求

触发规则：
只要用户隐含「提示词优化、改清楚指令、重写prompt、让AI更好理解」
相关意图，无需用户显性指令，自动执行优化并输出ABCD四版。
```

**来源**：https://github.com/aAAaqwq/AGI-Super-Team/tree/master/skills/prompt-optimizer