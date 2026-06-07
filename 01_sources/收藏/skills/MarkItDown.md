# MarkItDown

> 创建时间：2026-06-07
> 调研日期：2026-06-07
> 状态：已收藏，**待本地试用**

微软官方开源的 **Python 文档转 Markdown 工具**，专为 LLM 文本分析流程设计。GitHub 11w+ Star，自 2024-12 发布后 2 周内斩获 25k+ 星，是 LLM 时代最流行的文档预处理工具之一。

**GitHub**：[microsoft/markitdown](https://github.com/microsoft/markitdown)
**PyPI**：[markitdown](https://pypi.org/project/markitdown/)

---

## 核心定位

把任意格式文档转成"LLM 最爱"的 Markdown —— 主打**结构保留 + Token 高效**，输出可直接喂给 GPT-4o / Claude / 其他大模型做 RAG 或分析。

> Markdown is extremely close to plain text, with minimal markup or formatting, but still provides a way to represent important document structure. — README

与 `textract` 类似，但更专注于"保留文档结构 + 输出干净的 Markdown"。

---

## 支持的文件格式

| 格式 | 说明 |
|------|------|
| **PDF** | `.pdf` |
| **PowerPoint** | `.pptx` |
| **Word** | `.docx` |
| **Excel** | `.xlsx` / `.xls` |
| **图片** | EXIF 元数据 + OCR |
| **音频** | EXIF 元数据 + 语音转录 |
| **HTML** | `.html` |
| **文本格式** | CSV / JSON / XML |
| **ZIP** | 遍历内容 |
| **YouTube** | 视频 URL 转字幕 |
| **EPUB** | 电子书 |
| **Outlook** | 邮件消息 |

---

## 安装

```bash
# 推荐：全功能安装（覆盖所有格式）
pip install 'markitdown[all]'

# 按需安装（更省空间）
pip install 'markitdown[pdf, docx, pptx]'

# 从源码安装
git clone git@github.com:microsoft/markitdown.git
cd markitdown
pip install -e 'packages/markitdown[all]'
```

**环境要求**：Python 3.10+。建议用 venv 或 uv。

**音频/视频转录依赖**：
- **FFmpeg** 必须安装（解析音频/视频）
- 离线安装：把 `ffmpeg.exe` 和 `ffprobe.exe` 复制到 Python Scripts 目录

---

## 使用方式

### 命令行（最常用）

```bash
# 基础用法：重定向输出
markitdown path-to-file.pdf > document.md

# 指定输出文件
markitdown path-to-file.pdf -o document.md

# 管道输入
cat path-to-file.pdf | markitdown
```

### Python API

```python
from markitdown import MarkItDown

markitdown = MarkItDown()
result = markitdown.convert("test.xlsx")
print(result.text_content)
```

### 可选依赖矩阵

| 依赖 | 启用格式 |
|------|---------|
| `[all]` | 全部 |
| `[pdf]` | PDF |
| `[docx]` | Word |
| `[pptx]` | PowerPoint |
| `[xlsx]` / `[xls]` | Excel |
| `[outlook]` | Outlook 邮件 |
| `[az-doc-intel]` | Azure 文档智能 |
| `[audio-transcription]` | 音频转录（wav/mp3） |
| `[youtube-transcription]` | YouTube 字幕 |

---

## MCP 支持（重要）

MarkItDown **原生支持 MCP**（Model Context Protocol），可以作为 MCP Server 接入 Claude Desktop / Cursor / 其他 MCP 客户端，让 AI 直接调用转换能力。

这是它最近热度高的重要原因 —— 在 MCP 生态里，文档→Markdown 是高频需求。

具体配置参见 [MarkItDown MCP 文档](https://github.com/microsoft/markitdown)（需到仓库 README 找最新说明）。

---

## 安全注意事项 ⚠️

> MarkItDown performs I/O with the privileges of the current process. Like `open()` or `requests.get()`, it will access resources that the process itself can access.
> — README 安全声明

- **不要用 MarkItDown 处理不受信任的输入**
- 在不可信环境用 `convert_stream()` 或 `convert_local()` 等**窄 API**，不要用通用 `convert()`
- 攻击者可能构造恶意 Office 文档（宏、嵌入对象）利用解析器漏洞

---

## 实际效果评价（来自社区）

**优点**：
- ✅ 文档结构保留好（标题、列表、表格、链接）
- ✅ LLM 友好：Token 占用低，模型理解准确
- ✅ 格式覆盖全：一个工具解决 N 种文档
- ✅ 命令行 + API 双入口，易集成
- ✅ 微软官方维护 + 开源，活跃度高
- ✅ MCP 支持让它在 AI Agent 时代又火了一把

**缺点**：
- ❌ PDF 解析效果一般（**官方推荐用 PyMuPDF** 做高质量 PDF 处理）
- ❌ 输出主要面向 LLM，**不适合人类直接阅读**
- ❌ 复杂排版（多栏、嵌套表格）可能丢结构
- ❌ 音频/视频处理需额外装 FFmpeg

---

## 与同类工具对比

| 工具 | 定位 | 优势 | 劣势 |
|------|------|------|------|
| **MarkItDown** | LLM 预处理 | 结构保留好、格式全、MCP 支持 | PDF 一般 |
| **textract** | 通用文本提取 | 老牌、稳定 | 输出是纯文本，无结构 |
| **PyMuPDF** | PDF 解析 | PDF 效果最佳 | 只支持 PDF |
| **unstructured** | 文档解析 | 商业级、效果好 | 较重、依赖多 |
| **pandoc** | 文档互转 | 老牌、格式全 | 不专门为 LLM 优化 |

**选型建议**：
- **LLM/RAG 场景首选 MarkItDown**（结构 + 通用性最佳）
- **PDF 精度要求高**：用 PyMuPDF 单独处理 PDF
- **生产级文档解析**：考虑 unstructured

---

## 与我的工作流结合

### 场景 1：博客/文章收藏
看到 PDF/Word 格式的好文章 → `markitdown` 转 Markdown → 直接进 Obsidian 知识库

### 场景 2：飞书/邮件附件分析
下载 Office 附件 → `markitdown` → 喂给 Claude 分析总结

### 场景 3：批量资料预处理
RAG 知识库构建前，统一用 MarkItDown 批量转换

### 场景 4：MCP 工具集成
在 Claude Desktop / Cursor 里配 MarkItDown MCP Server，AI 直接调用

---

## 试用计划

- [ ] 本地 `pip install 'markitdown[all]'` 装一下
- [ ] 拿一份 PDF / Word / PPT 测试转换效果
- [ ] 配 MCP Server 接到 Claude Desktop
- [ ] 对比 PyMuPDF 处理同一份 PDF 的输出质量
- [ ] 评估是否接入 `xiaodongq.github.io` 博客工作流

---

## 参考资料

- GitHub: https://github.com/microsoft/markitdown
- PyPI: https://pypi.org/project/markitdown/
- 微软 AutoGen 团队出品：[microsoft/autogen](https://github.com/microsoft/autogen)
- 2024-12 发布：[IT之家报道](https://www.ithome.com/0/818/201.htm)
- 知乎教程：[一键转换任意文件为 Markdown](https://zhuanlan.zhihu.com/p/15343421980)
- CSDN：[MarkItDown MCP 支持](https://blog.csdn.net/LiuSid7/article/details/160187184)
