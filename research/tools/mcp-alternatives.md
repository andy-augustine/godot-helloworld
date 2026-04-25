# Godot MCP alternatives — research notes

Comparison of godot-mcp-pro (paid, what we use) vs. free open-source MCP servers vs. pure CLI.

| | |
|---|---|
| Researched | 2026-04-25 |
| Driver | Evaluating whether 6 new collaborators must install godot-mcp-pro ($5/seat × 6 = $30) |

## TL;DR

**Hybrid recommended.** Keep godot-mcp-pro on 1–2 lead seats (anyone doing playtest/QA — `capture_frames`, `record_frames`, `compare_screenshots` have no free equivalent and our `TESTING.md` is built around them). Free `hi-godot/godot-ai` (120+ tools, MIT, Asset Library) covers prototyping, scene authoring, error inspection for the rest of the team. Pure CLI is enough for CI/build automation only.

## The four tiers

| Tier | Cost | Tool count | Live editor? | Live runtime? | Best for |
|---|---|---|---|---|---|
| **godot-mcp-pro** | $5/seat | ~170 | ✓ | ✓ + frame capture / record / diff / Android | Lead/QA seats |
| **hi-godot/godot-ai** | Free (MIT) | 120+ | ✓ | ✓ partial — no rich frame capture | Most of the team |
| **Coding-Solo/godot-mcp** | Free (MIT) | ~CLI-driven | ✗ — restarts every time | stdout only | Light scripting tasks |
| **Pure CLI + editor scripts** | Free | — | ✗ | stdout only; LSP/DAP sockets available | CI, build automation, occasional one-shots |

## Free MCP alternatives — full landscape

Searched GitHub for "godot mcp" (224 repos). Credible candidates as of 2026-04-25:

| Repo | Stars | Last push | Lang | Architecture |
|---|---|---|---|---|
| **Coding-Solo/godot-mcp** | 3,238 | 2026-04-16 | TS+Node | CLI-driven; spawns `godot` for run/export/UID ops. **No live editor link.** [link](https://github.com/Coding-Solo/godot-mcp) |
| **tomyud1/godot-mcp** | 257 | 2026-04-21 | GDScript+plugin | Live editor plugin + WebSocket. **42 tools** across scenes/nodes/scripts/validate/run/errors/scene-tree, browser visualizer on :6510. [link](https://github.com/tomyud1/godot-mcp) |
| **hi-godot/godot-ai** | 99 | 2026-04-25 (active) | GDScript+Python | Live editor plugin + FastMCP HTTP. **120+ tools** — closest free analog to godot-mcp-pro. On Godot Asset Library. [link](https://github.com/hi-godot/godot-ai) |
| **satelliteoflove/godot-mcp** | 81 | 2026-04-24 | TS | Editor integration |
| **shameindemgg/godot-catalyst** | 1 | 2026-04-20 | GDScript | Claims 240+ tools — too new (1 star), unproven |
| **ryanmazzolini/minimal-godot-mcp** | 29 | 2026-04-24 | TS | LSP-only bridge: validate GDScript + DAP console buffer. Pairs with another MCP. [link](https://github.com/ryanmazzolini/minimal-godot-mcp) |
| **ee0pdt/Godot-MCP** | 540 | 2025-03-19 (stale) | GDScript | Plugin + Node server. Last push >1y ago — **stale**, do not adopt. |

**Recommendation:** `hi-godot/godot-ai` is the strong free pick for our team. Active commits, on the Godot Asset Library (in-editor install), MIT, 120+ tools matching the same socket-based pattern as godot-mcp-pro. **Not yet validated hands-on** — see caveats.

## Godot CLI capabilities (no MCP at all)

From official `command_line_tutorial.rst`:

- `--headless` — `--display-driver headless --audio-driver Dummy`
- `-s, --script <path>` — runs a script standalone (`res://...` or absolute)
- `--check-only` — parse-and-quit; pairs with `--script` for **CLI compile checks**
- `-e, --editor` — launches editor
- `--quit` / `--quit-after <N>` — quit after first iteration / N frames
- `--scene <path>` — run a specific scene with stdout/stderr capture
- `-d, --debug` — local stdout debugger
- `--log-file <path>` — write log to chosen path
- `--export-release / --export-debug / --export-pack <preset> <path>` — full export
- `--import` — start editor, import resources, quit (CI cache warm-up)
- `--lsp-port` / `--dap-port` — expose GDScript LSP and Debug Adapter Protocol on chosen ports
- `--write-movie <file>` — record deterministic frame-by-frame video

**No flag exists to dump scene tree from outside.** A `--script` that loads a scene and prints its tree is the workaround.

## Editor scripting (no plugin)

Two avenues, both work without any MCP:

- **Editor → Run Script** menu: runs a `.gd` file with a `_run()` function. Has full `EditorInterface` access, can mutate scene tree, save, print to Output panel.
- **`@tool` scripts and `EditorPlugin` classes**: run inside the editor, can introspect/mutate.

Workflow: write `res://tools/<task>.gd`, ask user to run via Editor → Run Script, capture stdout from Output panel pasted back, OR have the script write JSON to a file Claude reads. **Real and works**, but each round-trip needs human action — much higher latency than socket-based MCP.

## .tscn / .tres hand-editability

INI-like text format. AI-friendly for typical scenes. Gotchas:
- `load_steps` in header must match actual resource count (warns and recovers, but logs noise)
- `uid="uid://..."` required in 4.4+; Claude can't invent UIDs — omit and let Godot regenerate, or copy from existing
- `ext_resource` IDs (`id="1_abc"`) must stay consistent within file
- Sub-resources must appear before nodes referencing them
- Node paths are relative to scene root

**Reliable for**: small scenes (player, camera, room, door — exactly our project). **Error-prone for**: animation trees, complex tilemaps, themes, packed transforms.

## Honest decision matrix (for our team of 7)

| Dimension | godot-mcp-pro | hi-godot/godot-ai | CLI-only |
|---|---|---|---|
| Live editor scene-tree | full | strong | none |
| Live runtime debug / screenshots | yes | partial | run+stdout only |
| GDScript validate | tool call | tool call | `--check-only` |
| Iteration speed | fastest | near-equal | slowest |
| Cost / friction | $5×N + license tracking | uv install + plugin enable | nothing |

**For task types:**
- **Prototyping new features** → `hi-godot/godot-ai` (free) is enough
- **Bug fixes / one-line tweaks** → any tier; even pure files + `--check-only` is fine
- **Heavy frame-capture / visual QA** → **godot-mcp-pro keeps an edge**
- **CI / build automation** → CLI-only is correct

## Caveats

- I have **not** run `hi-godot/godot-ai` myself — feature claims come from README + active commit history (last push today). Worth a 30-min hands-on validation before committing the team.
- `shameindemgg/godot-catalyst` claims 240 tools but has 1 star and is too new; flagged, not endorsed.
- Per-seat install friction × 6 is the real consideration for godot-mcp-pro, not the $30 list price.
- Our `TESTING.md` patterns (`simulate_action`, `capture_frames`) are godot-mcp-pro-specific. Switching tier on a QA seat means rewriting them.
