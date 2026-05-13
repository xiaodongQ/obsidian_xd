# PPT-Master

网站：[PPT Master](https://hugohe3.github.io/ppt-master/)，上面有很多示例。ppt制作效果很好。

**用途**：用自然语言描述生成 PPTX 文件

---

## 安装步骤

```bash
# 1. 克隆仓库 GIT_LFS_SKIP_SMUDGE=1
git clone https://github.com/hugohe3/ppt-master

# 2. 安装依赖
cd ppt-master
pip install -r requirements.txt

# 3. 在 ppt-master 目录打开 Claude Code，用 prompt 创建 PPT
```

## 使用流程

1. 在 `ppt-master` 目录打开 Claude Code
2. 用自然语言描述 PPT 需求
3. AI 生成一版 PPT
4. 人工再改（降 token 消耗）

ppt效果示例：
![preview_magazine_garden](https://github.com/hugohe3/ppt-master/blob/main/docs/assets/screenshots/preview_magazine_garden.png)

---

## 快速本地生成 PPT（推荐）

如只需生成标准风格 PPT，可直接用 pptxgenjs 在任意目录生成：

```bash
cd /root/.openclaw/workspace/slides
# 创建 slides 目录和输出目录
mkdir -p slides/output

# 用 node 生成 PPT（无需完整 ppt-master workflow）
node make-cli-ppt.js   # 参考 /root/.openclaw/workspace/slides/make-cli-ppt.js
```

**主题配色（深色科技风）：**
```javascript
const theme = {
  primary: "1a1a2e",   // 深蓝黑
  secondary: "16213e", // 深蓝
  accent: "0f3460",    // 中蓝
  light: "e94560",     // 粉红强调
  bg: "f5f5f5"         // 浅灰背景
};
```

---

## 发布到飞书

用 lark-cli 上传并发送链接给用户：

```bash
# 1. 上传到飞书云盘
cd /root/.openclaw/workspace/slides/output
lark-cli drive +upload --file "./文件名.pptx"

# 2. 用飞书机器人发消息给用户
lark-cli im +messages-send --user-id "ou_用户open_id" --markdown "内容"
```

**lark-cli 常用命令：**
- `lark-cli auth status` — 检查认证状态
- `lark-cli docs +create --title "标题" --markdown "# 内容"` — 创建飞书文档
- `lark-cli drive +upload --file "./文件.pptx"` — 上传到云盘
- `lark-cli im +messages-send --user-id "ou_xxx" --markdown "内容"` — 发消息

---

## 工具位置

- ppt-master 项目：`/home/workspace/ppt-master-main/`
- lark-cli：`npm install -g @larksuite/cli`（已安装在 PATH）
- pptxgenjs：位于 `/root/.openclaw/workspace/slides/node_modules/pptxgenjs/`