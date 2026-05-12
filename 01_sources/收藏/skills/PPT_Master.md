# PPT-Master

**用途**：用自然语言描述生成 PPTX 文件（有点耗 token，建议先出一版再改）

---

## 安装步骤

```bash
# 1. 克隆仓库
git clone https://git-mirror.dahuatech.com/gh_hugohe3/ppt-master.git ppt-master

# 2. 安装依赖
cd ppt-master
pip install -r requirements.txt \
  --trusted-host pypi.org \
  --trusted-host files.pythonhosted.org \
  --trusted-host pypi.python.org

# 3. 在 ppt-master 目录打开 Claude Code，用 prompt 创建 PPT
```

## 使用流程

1. 在 `ppt-master` 目录打开 Claude Code
2. 用自然语言描述 PPT 需求
3. AI 生成一版 PPT
4. 人工再改吧改吧（降 token 消耗）

## 注意

仓库在内部 Git 镜像，外部可能无法直接访问