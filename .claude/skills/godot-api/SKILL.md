---
name: godot-api
description: |
  Look up Godot engine class APIs — methods, properties, signals, enums.
  Use when you need to find which class to use or look up specific API details.
context: fork
model: sonnet
agent: Explore
---

<!-- NOTE: context/model/agent fields lifted from godogen. Whether Claude Code
     honors them natively is verified in backlog/tooling-pipeline.md item #5.
     Until that's confirmed, this skill may run inline in the main context.  -->

# Godot API Lookup

$ARGUMENTS

## How to answer

1. Read `${CLAUDE_SKILL_DIR}/doc_api/_common.md` — index of ~128 common classes
2. If the class isn't there, read `${CLAUDE_SKILL_DIR}/doc_api/_other.md`
3. Read `${CLAUDE_SKILL_DIR}/doc_api/{ClassName}.md` — full API with descriptions for all methods, properties, signals, constants, and virtual methods
4. Return what the caller needs:
   - **Specific question** (e.g. "how to detect collisions") → return relevant methods/signals with descriptions
   - **Full API request** (e.g. "full API for CharacterBody3D") → return the entire class doc

Bootstrap if doc_api is empty: `bash .claude/skills/godot-api/tools/build.sh`
