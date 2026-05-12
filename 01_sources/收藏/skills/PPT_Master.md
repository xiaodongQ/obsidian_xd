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