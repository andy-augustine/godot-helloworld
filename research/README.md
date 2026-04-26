# Research

Source-of-truth notes from evaluations of external tools, frameworks, and approaches. **Read this folder before re-evaluating something we've already looked at** — the goal is to never have to do the same research twice.

## What's in here

| File | What it captures |
|---|---|
| [`tools/godogen.md`](tools/godogen.md) | Deep notes on htdt/godogen — verdict, what's adoptable, what's not |
| [`tools/godot-ai-builder.md`](tools/godot-ai-builder.md) | Deep notes on HubDev-AI/godot-ai-builder — skill list with relevance |
| [`tools/mcp-alternatives.md`](tools/mcp-alternatives.md) | Comparison of godot-mcp-pro (paid) vs free MCP alternatives + pure CLI |
| [`tools/godot-mcp-pro-internals.md`](tools/godot-mcp-pro-internals.md) | godot-mcp-pro architecture, input pipeline, CLI surface, extension points, license |
| [`tools/godot-drag-drop-api.md`](tools/godot-drag-drop-api.md) | Godot 4 native drag/drop API + canonical synthetic-drag recipe for `execute_game_script` |
| [`tools/godogen-playtest-deep-dive.md`](tools/godogen-playtest-deep-dive.md) | Focused dive: does godogen offer better playtest than mcp-pro? (No.) |
| [`tools/playtest-extension-strategy.md`](tools/playtest-extension-strategy.md) | Synthesis: should we extend mcp-pro, build sibling MCP, or build a CLI framework? Ranked actions. |

## How to use this folder

- **Before considering a new tool or approach**, check whether we've already evaluated it.
- **When something we evaluated changes** (a new release, license change, a feature we missed), update the existing file rather than writing a new one — keep one source of truth per tool.
- **When research turns into a follow-up** (a skill to write, a feature to try), add it to [`../backlog/`](../backlog/) with a back-reference to the research file. Don't put TODOs in research notes.

## Each tool file follows the same shape

1. **Repo + maintenance status** — URL, license, stars, last push date, alive vs. dead
2. **Verdict** — adopt / mine concepts / skip, in one sentence
3. **Hard constraints** — language requirements, platform requirements, dependencies that disqualify wholesale adoption
4. **What's actually in there** — concrete catalog of features/skills/concepts, with file paths cited
5. **What we'd lift** — concept-by-concept, with translatability rating
6. **Caveats** — what wasn't verified, where we'd need a hands-on test

## Long-term vision

This hello-world project is small enough to be a useful sandbox for developing **reusable Claude-Code-driven Godot workflows**: skills, conventions, hooks, doc templates, MCP usage patterns. Tooling/pipeline backlog items that mature here are candidates to extract into a portable starter kit that future game projects (card/deck, rogue-likes, other 2D platformers) can pull from with no re-research and no re-implementation.

That extraction happens later, not now. For today, the goal is to get the conventions written down once, in this repo, in a way that's portable in shape (skills as standalone Markdown, hooks as standalone shell scripts, conventions as standalone docs) so the eventual extraction is mostly file moves, not re-authoring.
