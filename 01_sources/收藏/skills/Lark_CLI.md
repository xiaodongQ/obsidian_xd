# Lark CLI（飞书命令行工具）

飞书官方开源的命令行工具，200+ commands，覆盖 11 个业务域，内置 19 个 AI Agent Skills。让 Agent 真正有手。

---

## 安装

```bash
npm install -g @larksuite/cli
npx skills add larksuite/cli -y -g
```

## 初始化与登录

```bash
lark-cli config init
lark-cli auth login --recommend    # 推荐最小权限登录
lark-cli auth status               # 检查认证状态
lark-cli doctor                    # 诊断工具
```

## 文档测试

```bash
lark-cli docs +create --title "Test" --markdown "# 飞书测试\n- 如果你看到这篇文档，说明 CLI 已经能创建飞书文档。"
```

---

## 核心命令速查

| 业务域 | 命令示例 |
|--------|---------|
| **文档** | `lark-cli docs +create --title "标题" --markdown "# 内容"` |
| **消息** | `lark-cli im +messages-send --user-id "ou_xxx" --markdown "内容"` |
| **云盘** | `lark-cli drive +upload --file "./文件路径"` |
| **日历** | `lark-cli calendar +agenda` |
| **通讯录** | `lark-cli contact +search-user --query "姓名"` |

## 发文件给用户

```bash
# 1. 上传到飞书云盘（需要 cd 到文件所在目录）
cd /root/.openclaw/workspace/slides/output
lark-cli drive +upload --file "./文件名.pptx"

# 2. 发消息通知用户（文件上传后拿到的 URL）
lark-cli im +messages-send --user-id "ou_用户open_id" --markdown "📎 文件：https://..."
```

**注意**：`--file` 参数必须是相对路径，且 cd 到目标目录。

---

## 认证信息

- 当前身份：bot（机器人身份）
- 认证状态：`lark-cli auth status --verify`
- 可用权限：文档、消息、云盘、日历、通讯录等

---

## 来源

- 仓库：github.com/larksuite/cli
- 安装：`npm install -g @larksuite/cli`
- 当前版本：v1.0.29