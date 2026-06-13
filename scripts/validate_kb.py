#!/usr/bin/env python3
"""
知识库验收脚本 V1.1
每次 push 前必须执行，全绿才允许提交
"""

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
WIKI_DIR = REPO_ROOT / "02_wiki"
REGISTRY_DIR = WIKI_DIR / "_registry"
SHARED_DIR = WIKI_DIR / "_shared"
TOPICS_FILE = REGISTRY_DIR / "topics.json"
SOURCE_DIR = REPO_ROOT / "01_sources"

RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"

errors = []
warnings = []


def check(name, condition, fail_msg, warn=False):
    if condition:
        print(f"{GREEN}\u2713{RESET} {name}")
    else:
        msg = f"{RED}\u2717{RESET} {name} \u2014 {fail_msg}" if not warn else f"{YELLOW}\u26a0{RESET} {name} \u2014 {fail_msg}"
        print(msg)
        if warn:
            warnings.append(msg)
        else:
            errors.append(msg)


def load_json(path):
    with open(path) as f:
        return json.load(f)


def has_frontmatter_tag(content: str) -> bool:
    return bool(re.search(r"^---\n.*?tags:", content, re.MULTILINE | re.DOTALL))


def main():
    print("=" * 50)
    print("知识库验收检查 V1.1")
    print("=" * 50)

    topics_data = load_json(TOPICS_FILE)
    registered_clusters = {t["clusterDir"] for t in topics_data["topics"]}

    print("\n--- 结构性验收 ---")
    for cluster in registered_clusters:
        cluster_path = WIKI_DIR / cluster
        check(f"V1 [{cluster}] _meta.md exists",
              cluster_path.exists() and (cluster_path / "_meta.md").exists(),
              f"{cluster}/_meta.md 不存在", warn=False)
        if (cluster_path / "_meta.md").exists():
            meta_content = (cluster_path / "_meta.md").read_text()
            wiki_files = re.findall(r'`([^`]+\.md)`', meta_content)
            for wf in wiki_files:
                check(f"V5 [{cluster}] wiki file exists: {wf}", (cluster_path / wf).exists(),
                      f"{cluster}/{wf} 不存在", warn=True)

    top_level_md = [f for f in WIKI_DIR.glob("*.md")]
    check("V2 无游离 Wiki 文件", len(top_level_md) == 0,
          f"02_wiki 根目录禁止放 .md 文件: {[f.name for f in top_level_md]}")

    for cluster in registered_clusters:
        check(f"V3 [{cluster}] 目录存在", (WIKI_DIR / cluster).exists(),
              f"{cluster}/ 目录不存在")

    actual_clusters = {d.name for d in WIKI_DIR.iterdir() if d.is_dir() and not d.name.startswith("_")}
    unregistered = actual_clusters - registered_clusters
    check("V4 所有 cluster 均已注册", len(unregistered) == 0,
          f"未注册: {unregistered}")

    check("V9 _template_meta.md 存在", (SHARED_DIR / "_template_meta.md").exists(),
          f"_shared/_template_meta.md 不存在")

    for parent in [WIKI_DIR, SOURCE_DIR]:
        proc_dir = parent / "_processing"
        if proc_dir.exists():
            gitkeep = proc_dir / ".gitkeep"
            check(f"V11 [{parent.name}/_processing] .gitkeep 存在", gitkeep.exists(),
                  f"{parent.name}/_processing/.gitkeep 不存在", warn=False)

    print("\n--- 命名规范验收 ---")
    # 禁止: 括号()（）、全角书名号《》『』「」、中文引号""''、尖括号<>、其他特殊符号
    FORBIDDEN_CHARS = set(
        '()\uff08\uff09\u300a\u300b\u300c\u300d\u300e\u300f\u201c\u201d\u2018\u2019'
        '<>{}[]!@#$%^&*+=|\\'
    )
    bad_name_files = []
    for md_file in WIKI_DIR.glob("**/*.md"):
        if md_file.name.startswith("_"):
            continue
        found = [c for c in md_file.name if c in FORBIDDEN_CHARS]
        if found:
            bad_name_files.append((md_file.relative_to(WIKI_DIR), found))
    check("V10 Wiki 命名无括号/全角/特殊字符", len(bad_name_files) == 0,
          f"违规: {[(str(f), cs) for f, cs in bad_name_files]}")

    print("\n--- Source 完整性验收 ---")
    archived_dir = SOURCE_DIR / "_archived"
    untagged = []
    for md_file in archived_dir.glob("*.md"):
        content = md_file.read_text()
        if not has_frontmatter_tag(content):
            untagged.append(md_file.name)
    check("V7 _archived 文件有 tags 元数据", len(untagged) == 0,
          f"无 tags: {untagged}", warn=True)

    clippings_dir = SOURCE_DIR / "_clippings"
    clippings_untagged = []
    if clippings_dir.exists():
        for md_file in clippings_dir.glob("*.md"):
            content = md_file.read_text()
            if not has_frontmatter_tag(content):
                clippings_untagged.append(md_file.name)
        check("V7b _clippings 文件有 tags 元数据", len(clippings_untagged) == 0,
              f"无 tags: {clippings_untagged}", warn=True)

    known_source_subdirs = {
        "_archived", "_clippings", "_processing", "_draft", "收藏",
        "知识库设计说明", "_excalidraw", "_assets"
    }
    orphan_sources = []
    for item in SOURCE_DIR.iterdir():
        if item.is_dir() and item.name not in known_source_subdirs:
            for f in item.glob("*.md"):
                orphan_sources.append(f"{item.name}/{f.name}")
    check("V7c 无孤儿 Source 目录", len(orphan_sources) == 0,
          f"未知目录下有 md 文件: {orphan_sources}", warn=True)

    for cluster in registered_clusters:
        meta_path = WIKI_DIR / cluster / "_meta.md"
        if meta_path.exists():
            content = meta_path.read_text()
            has_sources = "## 关联 Sources" in content
            has_wiki = "## 关联 Wiki" in content
            has_summary = "## 知识小结" in content
            complete = has_sources and has_wiki and has_summary
            check(f"V8 [{cluster}] _meta.md 内容完整", complete,
                  f"缺少: {'Sources' if not has_sources else ''} "
                  f"{'Wiki' if not has_wiki else ''} "
                  f"{'小结' if not has_summary else ''}",
                  warn=True)

    print("\n" + "=" * 50)
    if errors:
        print(f"{RED}\u2717 验收失败，共 {len(errors)} 个错误{RESET}")
        for e in errors:
            print(f"  {e}")
        print(f"\n{YELLOW}\u26a0 共 {len(warnings)} 个警告（可推进但建议修复）{RESET}")
        sys.exit(1)
    else:
        print(f"{GREEN}\u2713 验收通过！{RESET}")
        if warnings:
            print(f"{YELLOW}  （含 {len(warnings)} 个警告）{RESET}")
        sys.exit(0)


if __name__ == "__main__":
    main()