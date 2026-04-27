# godot-helloworld

A Metroid-style 2D platformer built with **Godot 4** (GDScript), driven by **Claude Code + Opus 4.7** through the **godot-mcp-pro** MCP server.

The point of the project: explore what AI-driven game development feels like when the model has live access to the editor — running the game, reading errors, inspecting the scene tree — instead of writing files blind.

---

## Stack

| Tool | Purpose |
|---|---|
| Godot 4.6+ | Game engine and editor |
| Node.js 18+ | Required for the MCP server |
| Claude Code CLI | AI code generation in the terminal |
| VS Code + godot-tools | External script editor |
| godot-mcp-pro | Live editor control (Claude sees errors, runs the game, reads scene state) — paid, $5 |

**Why godot-mcp-pro over plain Claude Code?** Without an MCP server, Claude writes files blind — no runtime feedback. godot-mcp-pro lets Claude launch the game, read debug output, inspect the scene tree, and iterate on real errors. Opus 4.7 is capable enough that you don't need a code-generation framework on top of this.

---

## Documentation

| File | What it covers |
|---|---|
| [`ROADMAP.md`](ROADMAP.md) | **Start here** — single TOC for "what's going on with this project" — active work, recent ships, backlog, lifecycle, where everything lives |
| [`SETUP.md`](SETUP.md) | End-to-end install for **macOS and Windows** — Godot, Node, VS Code, Claude Code, godot-mcp-pro, Git |
| [`STRUCTURE.md`](STRUCTURE.md) | Folder layout, data flow between scenes, Unreal/Unity analogies for the architecture |
| [`GODOT_PRIMER.md`](GODOT_PRIMER.md) | Godot/GDScript Rosetta stone for developers coming from **Unreal or Unity** — scenes vs prefabs, signals vs events, etc. |
| [`CLAUDE.md`](CLAUDE.md) | Project rules Claude Code follows on every session |
| [`tests/README.md`](tests/README.md) | How to drive the running game through MCP without fighting async/physics timing |
| [`plans/`](plans/) | In-progress multi-phase plans. Completed plans live in `plans/done/` for reference. |
| [`research/`](research/) | Source-of-truth notes from evaluations of external tools and approaches — read before re-evaluating something |
| [`backlog/`](backlog/) | Things we want to act on later, split into [`gamedev.md`](backlog/gamedev.md) (game features), [`tooling-pipeline.md`](backlog/tooling-pipeline.md) (game-dev tooling), and [`claude-collab.md`](backlog/claude-collab.md) (meta-collaboration process) |

---

## Daily workflow

```
┌─────────────────┐     WebSocket      ┌──────────────────┐
│   Claude Code   │ ◄────port 6505────► │   Godot Editor   │
│   (terminal)    │                    │  (plugin active) │
└────────┬────────┘                    └────────┬─────────┘
         │ edits files                          │ runs game
         ▼                                      ▼
    VS Code opens                       Output / Debug panel
    scripts on click
```

1. **Open Godot** with the project (the plugin auto-starts the WebSocket server on port 6505).
2. **Open a terminal** in the project directory.
3. **Start Claude Code**: `claude`.
4. Type **`/orient`** to anchor the session on the current ROADMAP, active plan (if any), and project conventions.
5. Give Claude a prompt — for major capabilities, ask for a phased plan first; for bug fixes / tweaks / one-shot edits, just describe what you want.
6. Claude uses godot-mcp-pro tools to create scenes, write scripts, and run the game — reading real errors back. Godot hot-reloads changed files automatically.
7. Type **`/wrapup`** at the end of the session to walk the post-ship docs sweep, archive shipped plans, surface backlog candidates, and verify clean tree before closing.

---

## Writing better prompts

Short prompts produce generic results. For real features, you'll want **detailed specs** — exact numbers, geometry, scope, non-obvious design decisions, and explicit "not in scope" callouts.

Short version: numbers beat adjectives, state what's NOT in scope, explain non-obvious decisions, use tables for anything repetitive. If you couldn't hand your prompt to a new human and get a recognizable result back, it's too vague. The `plans/` and `plans/done/` folders have real examples — pick one whose scope feels comparable to what you're trying to brief.

---

## Resources

- [Godot 4 Docs](https://docs.godotengine.org/en/stable/)
- [godot-mcp-pro on itch.io](https://y1uda.itch.io/godot-mcp-pro)
- [godot-mcp-pro GitHub](https://github.com/youichi-uda/godot-mcp-pro)
- [Godot Forum thread](https://forum.godotengine.org/t/godot-mcp-pro-162-tools-for-ai-powered-godot-development/135467)
- [Claude Code as a Godot Editor (dev blog)](https://vivecuervo7.github.io/dev-blog/p/claude-code-godot/)
- [Building a game — What if Claude writes ALL code? (DEV.to)](https://dev.to/datadeer/part-1-building-an-rts-in-godot-what-if-claude-writes-all-code-49f9)
- [Godot + Claude MCP Setup Tutorial (YouTube)](https://www.youtube.com/watch?v=qoVkETfryho)
- [AI Builds a Godot Game From Scratch (YouTube)](https://www.youtube.com/watch?v=THwZYWuOdZI)
- [Godogen (scaffold entire game from prompt)](https://github.com/htdt/godogen)
