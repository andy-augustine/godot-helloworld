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
| [`SETUP.md`](SETUP.md) | End-to-end install for **macOS and Windows** — Godot, Node, VS Code, Claude Code, godot-mcp-pro, Git |
| [`STRUCTURE.md`](STRUCTURE.md) | Folder layout, data flow between scenes, Unreal/Unity analogies for the architecture |
| [`GODOT_NOTES.md`](GODOT_NOTES.md) | Godot/GDScript ↔ Unreal/Unity Rosetta stone — scenes vs prefabs, signals vs events, etc. |
| [`TESTING.md`](TESTING.md) | How to drive the running game through MCP without fighting async/physics timing |
| [`CLAUDE.md`](CLAUDE.md) | Project rules Claude Code follows on every session |
| [`plans/`](plans/) | In-progress multi-phase plans. Completed plans live in `plans/done/` for reference. |
| [`research/`](research/) | Source-of-truth notes from evaluations of external tools and approaches — read before re-evaluating something |
| [`backlog/`](backlog/) | Things we want to act on later, split into [`tooling-pipeline.md`](backlog/tooling-pipeline.md) (portable) and [`gamedev.md`](backlog/gamedev.md) (project-specific) |
| [`early-requirements/`](early-requirements/) | Worked examples of detailed prompts that produced features in this repo |

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
4. Give Claude a prompt — see [`early-requirements/v1-animated-platformer.md`](early-requirements/v1-animated-platformer.md) for an example of a detailed spec.
5. Claude uses godot-mcp-pro tools to create scenes, write scripts, and run the game — reading real errors back.
6. Godot hot-reloads changed files automatically.

---

## Writing better prompts

Short prompts produce generic results. For real features, you'll want **detailed specs** — exact numbers, geometry, scope, non-obvious design decisions, and explicit "not in scope" callouts.

Start with [`early-requirements/v1-animated-platformer.md`](early-requirements/v1-animated-platformer.md) — it's a full spec of the animated-player phase of this project, specific enough that a fresh AI could rebuild what's here from the spec alone. The appendix breaks down the patterns that make a spec like that effective.

Short version: numbers beat adjectives, state what's NOT in scope, explain non-obvious decisions, use tables for anything repetitive. If you couldn't hand your prompt to a new human and get a recognizable result back, it's too vague.

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
