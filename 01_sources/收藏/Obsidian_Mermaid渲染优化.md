# Obsidian Mermaid 渲染优化 CSS 片段

> 用于 `.obsidian/snippets/mermaid-auto-fit.css`，让 Mermaid 图表在阅读/预览模式下自适应宽度、居中显示、整体缩小。

---

## CSS 片段

```css
/* Mermaid 图表自适应宽度 + 缩小显示 */
.mermaid svg {
  max-width: 100% !important;
  height: auto !important;
}

/* Mermaid 容器居中 */
.mermaid {
  overflow-x: auto !important;
  text-align: center !important;
}

/* 预览模式下自适应 */
.markdown-preview-view .mermaid svg {
  max-width: 100% !important;
  height: auto !important;
}

/* 阅读模式下自适应 + 缩小 */
.markdown-rendered .mermaid svg {
  max-width: 100% !important;
  height: auto !important;
  transform: scale(0.9) !important;
  transform-origin: top center !important;
}

/* 缩小 Mermaid 字体 */
.mermaid .nodeLabel,
.mermaid .edgeLabel {
  font-size: 12px !important;
}

/* 确保文本不被裁剪 */
.mermaid svg {
  overflow: visible !important;
}

.mermaid .node foreignObject {
  overflow: visible !important;
}
```

---

## 作用效果

| 效果 | 说明 |
|------|------|
| 宽度自适应 | `max-width: 100%` 防止图表溢出 |
| 整体缩小 | `scale(0.9)` 在阅读模式下缩小10% |
| 居中显示 | `text-align: center` |
| 字体缩小 | 节点和边的标签字体降为 12px |
| 防止裁剪 | `overflow: visible` 确保内容完整显示 |

---

## 使用方法

1. 将片段保存为 `.obsidian/snippets/mermaid-auto-fit.css`
2. 在 Obsidian 设置 → Appearance → CSS snippets 中启用该片段