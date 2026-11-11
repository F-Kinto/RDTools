---
name: utf8-lf-formatter
description: >
  This skill should be used whenever code files (.cpp, .h, .qml) are created or modified.
  It ensures all source files use UTF-8 encoding (no BOM) and LF line endings.
  Run after every code edit session to normalize file format automatically.
---

# UTF-8 / LF Formatter

## Purpose

Guarantee that every `.cpp`, `.h`, `.qml` (and `.hpp`, `.c`) file in the project is:
- **UTF-8 encoded** without BOM
- **LF line endings** (no CRLF)

This eliminates cross-platform encoding inconsistencies and VCS diff noise.

## When to Use

Trigger this skill **after every code update session** ¡ª any time a `.cpp`, `.h`, or `.qml` file has been created or edited. This includes:

- After writing or replacing code in any C++ or QML file
- After a build completes successfully
- Before committing changes to version control

## Workflow

1. Run the bundled script to scan and convert all target files:
   ```bash
   python3 scripts/ensure_utf8_lf.py <project_root>
   ```
   The script:
   - Recursively finds all `.cpp`, `.h`, `.qml`, `.hpp`, `.c` files
   - Skips `build/`, `.git/`, and other non-source directories
   - Detects encoding (UTF-8 ¡ú GB18030 ¡ú Latin-1 fallback)
   - Normalizes line endings to LF
   - Re-encodes as UTF-8 without BOM
   - Only rewrites files that actually changed
   - Prints a summary of converted files

2. If any files were converted, note them in the response to the user.

## Important Notes

- The script is idempotent ¡ª safe to run repeatedly; already-compliant files are untouched.
- BOM is always stripped to avoid Qt/QML parsing issues.
- Do NOT skip this step even for single-file edits ¡ª consistency matters.
