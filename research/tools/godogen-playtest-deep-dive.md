---
name: godogen-playtest-deep-dive
description: Focused dive into whether godogen offers any playtest/QA automation we'd lift — specifically for drag-and-drop scenarios
type: research
---

# godogen — playtest deep-dive

| | |
|---|---|
| Researched | 2026-04-26 |
| Companion to | [`godogen.md`](godogen.md) (strategic notes) |
| Question driving this dive | Does godogen offer better drag-and-drop / interactive playtest automation than godot-mcp-pro? |

## Verdict (one sentence)

**No.** Godogen is a code+asset *generation* system, not a *playtest* framework — its "visual feedback" loop validates generated artifacts at dev time, not interactive gameplay. For drag-and-drop QA, godot-mcp-pro's `simulate_*` + capture tooling is the right tool.

## Key findings

### 1. Playtest automation — none

Godogen has no playtest automation. The prior note ([`godogen.md`](godogen.md)) referenced "visual-qa.md" with "Static / Dynamic / Question" modes; the current repo structure (post the April 2026 GDScript→C# migration) has evolved and the QA-flavored framing in the prior note overstates what's actually there. What survives is **screenshot-based visual feedback on build artifacts** (does the generated scene look right? does the generated code compile? does the asset render at correct scale?), not interactive verification.

### 2. Input injection — none

No drag-and-drop tooling. No multi-step input simulator. No test harness for interactive verification. Godogen never injects synthetic input.

### 3. Capture pipeline — dev-time, not test-time

The capture wrapper exists for "frame-grounded self-repair" — screenshot, look at it with a vision model, decide whether the generated code/asset matches the visual target, iterate. There's no concept of "drive input then capture deterministic frames N..M" — it's single-shot snapshotting of whatever state happens to be on screen.

### 4. Honest comparison vs. godot-mcp-pro

For every playtest dimension that matters for the drag-and-drop scenario, godot-mcp-pro wins decisively:

| Dimension | godot-mcp-pro | godogen |
|---|---|---|
| Single screenshot of editor scene | `get_editor_screenshot` | own CLI wrapper (equivalent) |
| Capture an N-second runtime sequence | `capture_frames`, `record_frames` | none |
| Drive multi-step input then verify | `simulate_*` + `execute_game_script` | none |
| Visual diff between two states | `compare_screenshots` | (manual via vision model) |
| Headless / CI-friendly capture | yes (`play_scene` + capture tools) | yes (CLI-based) |
| Drag-and-drop specifically | possible via `simulate_sequence` (see [internals doc](godot-mcp-pro-internals.md)) | absent |

### 5. Drag-and-drop specifically — zero support

No mention of "drag", "drop", `InputEventMouseMotion`, multi-step mouse motion, or anything resembling drag testing in any accessible godogen doc. Confirmed via the structure search; the agent doing this dive could not find it because it isn't there.

### 6. Liftable for our drag-and-drop problem

Nothing beyond what the prior note already identified. The playtest angle yields **no new liftable concepts** for the drag-and-drop scenario.

## What this means for the bigger picture

The user's question was "does godogen support playtesting better than the MCP we're using?" The answer is a clean **no**. Godogen and godot-mcp-pro live in different lanes:

- **godogen**: gen-stage tooling (write the code, draw the asset, scaffold the scene, validate the artifact looks right). Excellent at that. Mute on QA.
- **godot-mcp-pro**: live editor + live runtime introspection and input simulation. Excellent at that. Mute on asset/code generation.

If we want better drag-and-drop testing, the answer is to push deeper on godot-mcp-pro (or its native primitives), not to swap to godogen. See:
- [`godot-mcp-pro-internals.md`](godot-mcp-pro-internals.md) — `simulate_sequence` already supports drag synchronously; just needs a wrapper
- [`godot-drag-drop-api.md`](godot-drag-drop-api.md) — Godot 4 native primitives + the canonical recipe
