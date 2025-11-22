#!/usr/bin/env python3

import os
import re
import sys
import time

BASE_DIR = "src"
MAIN_FILE = "main.lua"
OUTPUT_FILE = "out/sh_papi.lua"
ADMIN_MODS_DIR = "admin_mods"
ADMIN_PLACEHOLDER = "--[[ Admin Mod Loaders ]] --"

INCLUDE_RE = re.compile(r'(local\s+(\w+)\s*=\s*)?include\("([^"]+)"\)')


def process_file(rel_path: str) -> str:
    full_path = os.path.join(BASE_DIR, rel_path)
    if not os.path.exists(full_path):
        print(f"Error: File not found: {full_path}")
        sys.exit(1)

    with open(full_path, "r", encoding="utf-8") as f:
        content = f.read()

    def replace_include(match: re.Match) -> str:
        assignment_prefix = match.group(1) or ""
        include_path = match.group(3)
        processed = process_file(include_path)
        wrapped = f"(function()\n{processed}\nend)()"
        return f"{assignment_prefix}{wrapped}"

    return INCLUDE_RE.sub(replace_include, content)


def build_admin_mods_block() -> str:
    dir_path = os.path.join(BASE_DIR, ADMIN_MODS_DIR)
    if not os.path.isdir(dir_path):
        return ""

    parts = []
    for filename in sorted(os.listdir(dir_path)):
        if not filename.endswith(".lua"):
            continue

        rel_path = os.path.join(ADMIN_MODS_DIR, filename).replace("\\", "/")
        code = process_file(rel_path)
        parts.append(f"Add(function()\n{code}\nend)\n")

    return "\n".join(parts)


def apply_version_replacement(content: str) -> str:
    return content.replace("_PAPI_VERSION_", "_PAPI_VERSION_" + str(int(time.time())) + "_")


def main() -> None:
    processed_main = process_file(MAIN_FILE)

    admin_block = build_admin_mods_block()
    if admin_block:
        processed_main = processed_main.replace(ADMIN_PLACEHOLDER, admin_block)

    processed_main = apply_version_replacement(processed_main)

    out_dir = os.path.dirname(OUTPUT_FILE)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(processed_main)

    print(f"Output written to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
