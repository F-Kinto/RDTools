#!/usr/bin/env python3
"""Ensure all .cpp/.h/.qml files in the project are UTF-8 encoded with LF line endings.

Usage:
    python ensure_utf8_lf.py [project_root]

If project_root is omitted, defaults to the current working directory.
Only files that need changes are rewritten; unchanged files are skipped.
Prints a summary of converted files.
"""

import os
import sys

TARGET_EXTENSIONS = {'.cpp', '.h', '.qml', '.hpp', '.c'}


def convert_file(filepath: str) -> bool:
    """Read file, normalize to UTF-8 + LF. Return True if file was modified."""
    with open(filepath, 'rb') as f:
        raw = f.read()

    # Detect current encoding: try UTF-8 first, fallback to GBK/GB18030
    text = None
    for enc in ('utf-8-sig', 'utf-8', 'gb18030', 'gbk', 'latin-1'):
        try:
            text = raw.decode(enc)
            break
        except (UnicodeDecodeError, LookupError):
            continue
    if text is None:
        print(f"  SKIP (cannot decode): {filepath}")
        return False

    # Normalize line endings to LF
    normalized = text.replace('\r\n', '\n').replace('\r', '\n')

    # Encode as UTF-8 (no BOM)
    new_bytes = normalized.encode('utf-8')

    if new_bytes == raw:
        return False

    with open(filepath, 'wb') as f:
        f.write(new_bytes)
    return True


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    root = os.path.abspath(root)

    changed = []
    scanned = 0

    for dirpath, _dirnames, filenames in os.walk(root):
        # Skip hidden and build directories
        rel = os.path.relpath(dirpath, root)
        if any(part.startswith('.') or part in ('build', 'cmake-build-', 'node_modules')
               for part in rel.split(os.sep)):
            continue
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext in TARGET_EXTENSIONS:
                fpath = os.path.join(dirpath, fname)
                scanned += 1
                if convert_file(fpath):
                    changed.append(fpath)

    print(f"\nScanned {scanned} files, converted {len(changed)}:")
    for fp in changed:
        print(f"  {fp}")


if __name__ == '__main__':
    main()
