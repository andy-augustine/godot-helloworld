---
name: playtest-extension-strategy
description: Synthesis — should we extend godot-mcp-pro, build a sibling MCP, or build a CLI framework? Answers a 4-question brief about drag/drop playtest, with ranked actions.
type: strategy
---

# Playtest extension strategy

| | |
|---|---|
| Date | 2026-04-26 |
| Companion docs | [godot-mcp-pro-internals.md](godot-mcp-pro-internals.md), [godot-drag-drop-api.md](godot-drag-drop-api.md), [godogen-playtest-deep-dive.md](godogen-playtest-deep-dive.md), [godogen.md](godogen.md), [godot-ai-builder.md](godot-ai-builder.md), [mcp-alternatives.md](mcp-alternatives.md), [../../TESTING.md](../../TESTING.md) |
| Triggering scenario | Son's drag-and-drop mechanic could not be playtested via MCP |

## TL;DR

The drag-and-drop failure was **not** a missing API — both Godot 4 and godot-mcp-pro already have everything needed. It was a **knowledge gap**: setting `button_mask` on motion events, disabling input accumulation, and running the whole sequence inside **one** call. The fix is a thin wrapper, not a new system. Ranked actions:

1. **Document Pattern 1 + drag recipe in TESTING.md** (~30 min). Closes the gap immediately.
2. **Add a `simulate_drag` helper** — either an MCP extension on the godot-mcp-pro addon side (~20 lines GDScript, no server rebuild) or a Claude skill that emits Recipe A. (1–2 hrs)
3. **Defer**: forking godot-mcp-pro, building a sibling MCP, or building a richer CLI framework. None of those are needed for drag-and-drop, and each has real cost.

## Answers to the four questions

### a) Is there a Godot 4 API that would help with drag-and-drop playtest?

**Yes.** The primitives are `Input.parse_input_event(event)` plus `InputEventMouseButton` and `InputEventMouseMotion`. Two non-obvious requirements:

- Every motion event between press and release **must** set `button_mask = MOUSE_BUTTON_MASK_LEFT`. Without this Godot's GUI dispatcher never recognises a held button → `_get_drag_data` / `_can_drop_data` never fire. This is the #1 silent failure mode (documented in [GUT issue #608](https://github.com/bitwes/Gut/issues/608)).
- `Input.use_accumulated_input = false` for the duration of the test, otherwise stepped motion events are merged into one big jump and the drag system observes a teleport, not a drag.

Plus pacing: `await get_tree().physics_frame` between events.

The full canonical recipe (both UI Control flavor and custom-physics 2D flavor) is in [godot-drag-drop-api.md §3](godot-drag-drop-api.md). Copy-paste-ready for `execute_game_script`.

`Input.warp_mouse` does **not** generate motion events (cursor teleport only). `Input.action_press` doesn't reach `_input()`. Both are dead ends for drag tests — easy mistakes that look right but produce no signal.

### b) Does godogen support drag-and-drop better than godot-mcp-pro?

**No.** Godogen is gen-stage tooling (write the code, draw the asset, scaffold the scene), not a playtest framework. It has no input simulation, no multi-step sequencing, no test harness for interactive verification. Its "visual feedback loop" validates artifacts at dev time — single screenshots, not driven sequences. See [godogen-playtest-deep-dive.md](godogen-playtest-deep-dive.md).

For our drag-and-drop scenario, **godot-mcp-pro decisively wins**. Godogen and mcp-pro live in different lanes; the answer is to push deeper on mcp-pro, not swap.

### c) Do we have enough access to godot-mcp-pro to extend it?

**Yes for our own use; no for redistribution.**

Source is fully on disk at `/Users/claudeprojectlt8/code/tools/godot-mcp-pro/115334_godotmcpprov1.12.0/`:

- **Server**: TypeScript. Tools registered in `/server/src/tools/*.ts` via `server.tool(name, desc, schema, handler)` calling `godot.sendCommand(...)`.
- **Addon**: GDScript. Commands dispatched via `/addons/godot_mcp/command_router.gd`; input handlers in `/addons/godot_mcp/commands/input_commands.gd`; events injected via `/addons/godot_mcp/mcp_input_service.gd` using `Input.parse_input_event` and `get_viewport().push_input(event, true)`.
- Adding a new tool: ~3 file edits (server tool, addon command, router). For drag specifically: `simulate_sequence` already exists and can express drag — a `simulate_drag(from, to, steps)` is just a generator.
- **License**: proprietary. Personal/commercial use allowed; redistribution and "modify and redistribute as a competing product" forbidden. We can patch our local copy; we cannot share patches.

What's already enough without code changes:

- `simulate_sequence` accepts `mouse_button` and `mouse_motion` events with `button_mask`, `position`, `relative`. Build the waypoint array on the Claude side and send one call. Frame-accurate, no per-step latency. Example payload in [godot-mcp-pro-internals.md §2](godot-mcp-pro-internals.md).
- `execute_game_script` runs arbitrary GDScript inside the running game in one round-trip. Recipe A from [godot-drag-drop-api.md §3](godot-drag-drop-api.md) drops in directly.

So **two paths** without forking:
- Use `simulate_sequence` with a Claude-side waypoint generator (zero server changes; Claude composes the JSON).
- Use `execute_game_script` with the canonical recipe (zero server changes; no MCP-side input model needed at all).

What would warrant patching the addon: making `simulate_drag` a first-class tool so future Claude sessions don't need to know the recipe. That's a 20-line addition to `input_commands.gd`. No server rebuild needed if we register the new command in `command_router.gd` only. Local-only, no redistribution issues.

Borrowing from godogen: per [godogen.md](godogen.md), nothing godogen-specific is worth lifting for the drag-and-drop scenario. The `godot-api` doc-lookup skill remains liftable for general use, but it's orthogonal to playtest.

### d) Can we use the CLI fallback if the MCP isn't available?

**Yes, with caveats.** The CLI is implemented at `/server/src/cli.ts`. Build first via `node build/setup.js install` in the server directory, then:

```bash
node /path/to/server/build/cli.js --help                       # discover groups
node /path/to/server/build/cli.js input click --x 100 --y 200  # one-shot
node /path/to/server/build/cli.js input key --key W --duration 0.5
```

Command groups: `project`, `scene`, `node`, `script`, `editor`, `input`, `runtime`. The CLI connects to the same Godot WebSocket the MCP server uses (port 6505, falls back 6510-6514). It invokes the same tool implementations — no separate code path.

**Caveats**:
- The Godot editor must still be running (CLI is a thin WebSocket client; the addon does the actual work).
- For drag specifically, the CLI is **worse** than MCP for the same reason: each `input` invocation is a separate process → separate WebSocket round-trip → game advances ~30+ frames between calls. The async-latency problem from `TESTING.md` applies just as much.
- CLI shines for: CI scripts, build automation, single-shot input, situations where MCP isn't loaded. Not for multi-step sequences with timing constraints.
- For drag from the CLI, the working pattern would be: write Recipe A as a `.gd` file, then `cli.js editor exec --path res://qa/test_drag.gd` (or pipe via `editor exec --code`). One call, the script does the loop internally. Same trick as `execute_game_script` over MCP, just delivered via CLI.

## Recommendation: ranked

### 1. Update TESTING.md with Pattern 1 + drag recipe (HIGH value, 30 min)

The recipe in [godot-drag-drop-api.md §3](godot-drag-drop-api.md) needs to be visible to future Claude sessions on this project (and the son's project). Without it, sessions repeat the silent-failure pattern. Add a "Pattern 4: synthetic drag-and-drop" section to `TESTING.md` with the recipe verbatim and the three pitfalls (button_mask, accumulation, single-call discipline).

### 2. Write a `simulate_drag` Claude skill (MEDIUM value, 1–2 hrs)

Skill in `~/.claude/skills/` (or per-project `.claude/skills/`) named `godot-drag-test`. Trigger phrases: "test drag", "playtest drag", "verify drag and drop". Skill body emits Recipe A with substituted node path / from / to / steps. Skill is portable across Godot projects, no plugin needed.

This is preferable to patching godot-mcp-pro because (a) it works for any user without a paid plugin, (b) it's redistributable, (c) it's entirely under our control.

### 3. (Optional) Patch godot-mcp-pro addon with `simulate_drag` (LOW priority, 1 hr)

Add a method to `/addons/godot_mcp/commands/input_commands.gd` that accepts `(from: Vector2, to: Vector2, steps: int, frame_interval: int, button: int)` and generates the same event sequence `simulate_sequence` would receive — including `button_mask` on motions and toggling `Input.use_accumulated_input` for the duration. Register in `command_router.gd`. Add the matching tool definition to `/server/src/tools/input-tools.ts` (just the Zod schema + `godot.sendCommand` line; the addon does the work).

Why low-priority: licensing forbids redistribution of the patched addon. The fix only benefits us locally, and we already have paths #1 and #2 that don't require patching. Worth doing only if (a) we end up running drag tests very frequently and (b) Recipe A's verbosity in `execute_game_script` calls becomes annoying.

### 4. (Defer) Build a sibling MCP or richer CLI framework

Not justified by the drag-and-drop problem. Reasons to defer:

- **godot-mcp-pro is a strict superset** of every free MCP we evaluated ([mcp-alternatives.md](mcp-alternatives.md)). A sibling MCP focused on QA would duplicate `play_scene`, `get_game_screenshot`, `execute_game_script`, etc.
- The drag gap is closed by skill + recipe (option #2), no new server needed.
- A "richer CLI framework" would be the right answer for **CI/automation** (where MCP can't run), not for interactive playtest. If/when we have a CI need, revisit.
- We have unverified options (`hi-godot/godot-ai`, the Claude-side `executre_game_script` workflow) that could obsolete a sibling MCP before we'd finish building it.

## Concrete `simulate_drag` design (for whichever path we pick)

If/when we implement option #2 or #3:

**Inputs**:
- `from: Vector2` — start position (viewport pixels)
- `to: Vector2` — end position
- `steps: int = 12` — number of motion events between press and release
- `frames_per_step: int = 2` — physics frames between motion events
- `button: int = MOUSE_BUTTON_LEFT`
- `flavor: "ui" | "node" | "auto"` — observation strategy ("ui" reads `gui_is_dragging`, "node" reads a `target_node_path` global_position, "auto" reports both)

**Output**:
- `events_dispatched: int`
- `dragging_at_step_2: bool` (early signal whether the drag system engaged)
- `drag_successful: bool` (post-release `gui_is_drag_successful()`)
- `final_position: Vector2` (target node, if "node" flavor)
- `screenshots: [path]` (if `capture: true`, one PNG per N steps)

**Body** (for the addon-patch flavor): assembles the same event list `simulate_sequence` would, plus toggles `Input.use_accumulated_input`, plus optionally calls `get_viewport().get_texture().get_image().save_png(...)` per step.

**Body** (for the skill flavor): emits a templated `execute_game_script` call containing Recipe A with substituted paths/positions.

Either way, the user-visible interface is identical and the behavior is identical.

## Things explicitly out of scope today

- **Sibling MCP server**. Justified only if we have a need MCP-pro can't serve. Drag-and-drop is not such a need.
- **Forking and redistributing godot-mcp-pro**. License-forbidden.
- **Adopting godogen wholesale**. .NET/C# lock; see [godogen.md](godogen.md).
- **Switching the team's MCP tier**. Already settled in [mcp-alternatives.md](mcp-alternatives.md).
- **Movie Maker (`--write-movie`) for drag verification**. Overkill; PNG-per-step inside `execute_game_script` is enough.

## Open spikes (future, not now)

- **Drag tests on touch input** (mobile) — `InputEventScreenTouch` + `InputEventScreenDrag` are the touch-flavored equivalents. Recipe would translate. Not relevant for the desktop game in question.
- **Drag tests over network play** — synthetic input on a host vs. observation on a client. Out of scope; the target game is single-player.
- **Verifying drag preview visually** — would require `compare_screenshots` against a golden image during the drag. Possible with godot-mcp-pro's `compare_screenshots`, but expensive in tokens. Defer until needed.
