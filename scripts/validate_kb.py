#!/usr/bin/env python3
"""
知识库验收脚本 V1.0
每次 push 前必须执行，全绿才允许提交
"""

import json
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
WIKI_DIR = REPO_ROOT / "02_wiki"
REGISTRY_DIR = WIKI_DIR / "_registry"
SHARED_DIR = WIKI_DIR / "_shared"
TOPICS_FILE = REGISTRY_DIR / "topics.json"

RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"

errors = []
warnings = []


def check(name, condition, fail_msg, warn=False):
    if condition:
        print(f"{GREEN}✓{RESET} {name}")
    else:
        msg = f"{RED}✗{RESET} {name} — {fail_msg}" if not warn else f"{YELLOW}⚠{RESET} {name} — {fail_msg}"
        print(msg)
        if warn:
            warnings.append(msg)
        else:
            errors.append(msg)


def load_json(path):
    with open(path) as f:
        return json.load(f)


def main():
    print("=" * 50)
    print("知识库验收检查 V1.0")
    print("=" * 50)

    # Load topics registry
    topics_data = load_json(TOPICS_FILE)
    registered_clusters = {t["clusterDir"] for t in topics_data["topics"]}

    # V1: Each cluster has _meta.md
    print("\n--- 结构性验收 ---")
    for cluster in registered_clusters:
        cluster_path = WIKI_DIR / cluster
        check(f"V1 [{cluster}] _meta.md exists", cluster_path.exists() and (cluster_path / "_meta.md").exists(),
              f"{cluster}/_meta.md 不存在", warn=False)
        # V5: _meta.md wiki files exist
        if (cluster_path / "_meta.md").exists():
            meta_content = (cluster_path / "_meta.md").read_text()
            wiki_files = re.findall(r'`([^`]+\.md)`', meta_content)
            for wf in wiki_files:
                check(f"V5 [{cluster}] wiki file exists: {wf}", (cluster_path / wf).exists(),
                      f"{cluster}/{wf} 不存在", warn=True)

    # V2: All wiki files in clusters
    all_wiki_files = list(WIKI_DIR.glob("*/**/*.md"))
    all_wiki_files = [f for f in all_wiki_files if f.name != "_meta.md"]
    top_level_wiki = [f for f in WIKI_DIR.glob("*.md")]
    orphan_files = top_level_wiki  # Any .md directly under 02_wiki/ is orphan

    # V2: No orphan wiki files
    orphan_names = [f.name for f in orphan_files]
    check("V2 无游离 Wiki 文件", len(orphan_files) == 0,
          f"以下文件在 cluster 外: {orphan_names}")

    # V3: All registered clusterDirs exist
    for cluster in registered_clusters:
        check(f"V3 [{cluster}] 目录存在", (WIKI_DIR / cluster).exists(),
              f"{cluster}/ 目录不存在")

    # V4: All cluster dirs are registered
    actual_clusters = {d.name for d in WIKI_DIR.iterdir() if d.is_dir() and not d.name.startswith("_")}
    unregistered = actual_clusters - registered_clusters
    check("V4 所有 cluster 均已注册", len(unregistered) == 0,
          f"未注册: {unregistered}")

    # V9: _template_meta.md exists
    check("V9 _template_meta.md 存在", (SHARED_DIR / "_template_meta.md").exists(),
          f"_shared/_template_meta.md 不存在")

    # V10: Wiki naming (no spaces, no special chars except -_.)
    print("\n--- 命名规范验收 ---")
    bad_name_files = []
    for md_file in WIKI_DIR.glob("**/*.md"):
        if md_file.name.startswith("_"):
            continue
        if re.search(r"\s|[^\w\u4e00-\u9fff\-_\.]", md_file.name):
            bad_name_files.append(md_file.relative_to(WIKI_DIR))
    check("V10 Wiki 命名无空格/特殊字符", len(bad_name_files) == 0,
          f"违规文件: {[str(f) for f in bad_name_files]}")

    # V7: _archived files have tags (check frontmatter)
    print("\n--- Source 完整性验收 ---")
    archived_dir = REPO_ROOT / "01_sources" / "_archived"
    untagged = []
    for md_file in archived_dir.glob("*.md"):
        content = md_file.read_text()
        if not re.search(r"^---\n.*?tags:", content, re.MULTILINE):
            untagged.append(md_file.name)
    check("V7 _archived 文件有 tags 元数据", len(untagged) == 0,
          f"无 tags: {untagged}", warn=True)

    # V8: _meta.md content completeness
    for cluster in registered_clusters:
        meta_path = WIKI_DIR / cluster / "_meta.md"
        if meta_path.exists():
            content = meta_path.read_text()
            has_sources = "## 关联 Sources" in content
            has_wiki = "## 关联 Wiki" in content
            has_summary = "## 知识小结" in content
            complete = has_sources and has_wiki and has_summary
            check(f"V8 [{cluster}] _meta.md 内容完整", complete,
                  f"缺少: {'Sources' if not has_sources else ''} {'Wiki' if not has_wiki else ''} {'小结' if not has_summary else ''}",
                  warn=True)

    # Summary
    print("\n" + "=" * 50)
    if errors:
        print(f"{RED}✗ 验收失败，共 {len(errors)} 个错误{RESET}")
        for e in errors:
            print(f"  {e}")
        print(f"\n{YELLOW}⚠ 共 {len(warnings)} 个警告（可推进但建议修复）{RESET}")
        sys.exit(1)
    else:
        print(f"{GREEN}✓ 验收通过！{RESET}")
        if warnings:
            print(f"{YELLOW}  （含 {len(warnings)} 个警告）{RESET}")
        sys.exit(0)


if __name__ == "__main__":
    main()