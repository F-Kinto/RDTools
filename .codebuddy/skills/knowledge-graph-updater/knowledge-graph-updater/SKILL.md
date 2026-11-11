---
name: knowledge-graph-updater
description: >
  This skill should be used after every bug fix, feature implementation, or code modification.
  It updates the project knowledge graph file (.workbuddy/KNOWLEDGE_GRAPH.md) to reflect
  the latest changes, ensuring the knowledge base stays in sync with the codebase.
---

# Knowledge Graph Updater

## Purpose

Keep the project knowledge graph file (`.workbuddy/KNOWLEDGE_GRAPH.md`) up-to-date after every code change. This ensures future sessions and team members have accurate, current documentation of the project's architecture, features, and change history.

## When to Use

Trigger this skill **after completing any of the following**:

- Bug fix or issue resolution
- New feature implementation
- Refactoring or architecture change
- Configuration or dependency change
- Any non-trivial code modification

## Workflow

1. **Identify what changed**: Determine the scope of the modification:
   - Which files were modified?
   - What was the nature of the change? (bug fix / new feature / refactor / config)
   - Which module(s) or component(s) are affected?

2. **Read the existing knowledge graph**:
   - File path: `.workbuddy/KNOWLEDGE_GRAPH.md` (relative to project root)
   - Understand the current structure and sections

3. **Update the relevant sections** based on the change type:

   | Change Type | Sections to Update |
   |-------------|-------------------|
   | Bug fix | `变更历史` — add entry describing the fix and root cause |
   | New feature | `功能模块清单` (if new button/feature), `变更历史`, optionally `架构设计` or `组件设计模式` |
   | Refactor | `架构设计`, `组件设计模式`, `变更历史` |
   | Config/deps | `项目概览`, `变更历史` |
   | Layout change | `布局比例`, `架构设计`, `变更历史` |

4. **Add a changelog entry** under `变更历史` section:
   ```markdown
   ### YYYY-MM-DD: <short description>
   - **File**: `path/to/file.ext` — what changed
   - **Root cause / motivation**: why the change was needed
   - **Result**: what the user-visible effect is
   ```

5. **Do NOT**:
   - Remove existing entries from `变更历史` (append only)
   - Overwrite the entire file — use targeted edits
   - Add verbose or redundant descriptions — keep entries concise

6. **Update `待办/规划`** section if the change completes or adds a todo item.

## Changelog Entry Format

Each entry in `变更历史` must include:
- **Date** in `YYYY-MM-DD` format
- **Title** summarizing the change in one line
- **Bullet list** of specific modifications with file paths

Keep descriptions under 2 lines per bullet. Focus on *what* and *why*, not implementation details.

## Important Notes

- The knowledge graph is a living document — it must reflect the current state of the codebase, not just historical snapshots.
- If `.workbuddy/KNOWLEDGE_GRAPH.md` does not exist, create it with the standard structure.
- Always use `replace_in_file` for updates, never rewrite the entire file.
