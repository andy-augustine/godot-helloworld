# Drag-recipe validation results

| | |
|---|---|
| Validated | 2026-04-26 (multiple iterations, hands-off final pass) |
| Godot version | 4.6.2-stable (official, hash `71f334935`) |
| Runner | `tests/run_drag_recipe.gd` (direct-invocation harness) |
| Companion docs | [`research/tools/godot-4.6-drag-test-current-intel.md`](../research/tools/godot-4.6-drag-test-current-intel.md), [`TESTING.md`](../TESTING.md) Pattern 4 |

## Definitive findings

### What works ✅

1. **Direct method invocation** — `target_slot._can_drop_data(pos, data)` + `target_slot._drop_data(pos, data)` from `execute_game_script` works perfectly for testing slot drop-handling logic. All four scenarios (equip, swap, deactivate, two negative-control rejections) pass deterministically. This is what `tests/run_drag_recipe.gd` does.
2. **MCP `simulate_mouse_click` triggers `_gui_input`** — `count=2` (press + release) on the source SkillCard when clicked at its center. Confirms the addon-side input plumbing reaches the GUI dispatcher correctly.
3. **MCP `simulate_sequence` with `frame_delay=0` triggers `_gui_input`** — events delivered same-frame, all reach GUI.
4. **Polled mouse state IS updated by synthetic events** — `Input.parse_input_event(press)` sets `Input.get_mouse_button_mask()` to `1` and `Input.is_mouse_button_pressed(LEFT)` to `true`. Not the broken layer.

### What doesn't work, definitively ❌

1. **`Input.parse_input_event(event)` from inside `execute_game_script` does NOT trigger `_gui_input`** — `count=0` even after waiting 500 ms. Same for `Viewport.push_input(event)` from the same context. The events reach the input queue (polled state updates), but never reach Control GUI dispatch. The reason is unknown; the most likely cause is that the `_cmd_execute_script` runtime context schedules differently than a normal frame callback. **Implication: drag tests cannot be written as a single inline script body in `execute_game_script`.**
2. **MCP `simulate_sequence` with `frame_delay > 0`** (queued path) — events also don't reach `_gui_input`. Likely a separate quirk in the addon's queued-dispatch path. Workaround: use `frame_delay=0` and dispatch the entire sequence at once; or chain `simulate_mouse_click` + `simulate_mouse_move` calls separately with Bash sleeps between.
3. **Even with events reaching `_gui_input` correctly (via MCP `simulate_sequence frame_delay=0` post-patch), the GUI drag state machine does not engage.** `_get_drag_data` is not called, `gui_is_dragging` stays `false`, no `_drop_data` fires on the target. Source card receives all 9 events on its `gui_input`, target slot receives 0. Root cause not isolated in this session — likely either:
   - Godot's drag-detection requires a specific event ordering or timing that synthetic events don't match
   - Synthetic events skip a hidden gating step the OS-event path goes through
   - The `_cmd_execute_script` context interferes with frame-by-frame state machine progression
   This is the question the queued **overnight Godot 4.6 community crawl** (backlog #12) is best positioned to answer.

### What we patched

`addons/godot_mcp/mcp_input_service.gd` — `_dispatch_event()` now honors an explicit `unhandled: false` in the event payload instead of always auto-promoting motions with `button_mask>0` to `push_input(event, true)`. The auto-promotion still happens when no `unhandled` key is provided (preserves the camera-pan use case the original was written for). Local patch only — license forbids redistribution.

```gdscript
# Before:
var force_unhandled: bool = event_data.get("unhandled", false)
if not force_unhandled and event is InputEventMouseMotion and event.button_mask != 0:
    force_unhandled = true

# After (the patch):
var force_unhandled: bool
if event_data.has("unhandled"):
    force_unhandled = bool(event_data.get("unhandled"))
else:
    force_unhandled = event is InputEventMouseMotion and event.button_mask != 0
```

This patch is necessary for any future drag-via-MCP-tools test to route events to GUI correctly. Without it, motions silently route to `_unhandled_input` and Control hit-testing is bypassed.

## What this means for the drag-test skill we set out to build

**The "synthetic drag-and-drop test" Claude skill does not graduate.** Not because Recipe A is wrong (it's correct in normal Godot 4.6 contexts per the crawl), but because:

1. We can't reliably exercise the GUI drag state machine from `execute_game_script` (the only way Claude can talk to the running game via MCP).
2. The MCP plugin's input-simulation tools (`simulate_*`) get events to `_gui_input` post-patch, but the drag state machine still doesn't engage. We don't know why.
3. Until we know why, packaging this as a skill would be packaging silent failures — exactly the kind of thing that wastes future sessions.

What replaces it: **the direct-invocation runner at `tests/run_drag_recipe.gd`**. It's a unit test of slot drop-handling logic — not an end-to-end drag test, but it catches regressions in the routing rules deterministically. Re-run after any change to `SkillCardSlot.gd` or `SkillsPanel.gd`.

## Observed runner output — direct invocation modes

```
baseline: active=- | inv1=turbo | inv2=high_jump | speed=1.0 | jump=1.0
mode1 (equip turbo): can_drop=true
after mode1: active=turbo | inv1=high_jump | inv2=- | speed=1.5 | jump=1.0
mode2 (swap to high_jump): can_drop=true
after mode2: active=high_jump | inv1=turbo | inv2=- | speed=1.0 | jump=1.5
mode3 (deactivate): can_drop=true
after mode3: active=- | inv1=turbo | inv2=high_jump | speed=1.0 | jump=1.0
mode4 (inv1→inv2 reject): can_drop=false (expect false)
mode4b (inv1→inv1 reject): can_drop=false (expect false)
```

All positive modes succeed; both negative-control rejections succeed. Slot logic is correct.

## What the overnight crawl should investigate

Pinned questions for backlog #12 to chase:

1. **Why does the GUI drag state machine NOT engage when synthetic events reach `_gui_input` correctly with the right button_mask, polled state, and threshold-exceeding motions?** This is the deepest unanswered question. Likely needs Godot source diving into `viewport.cpp`'s drag-detect code path.
2. **Is there a known difference between events from `_cmd_execute_script` context vs. normal `_process` callbacks** that affects GUI dispatch ordering? GUT's tests run in `_process` and apparently work. We don't.
3. **Are there community examples of MCP-style drag testing**, where input is injected from a remote process via WebSocket → autoload → game's `_process`? Same architecture as godot-mcp-pro. If anyone's solved this, what did they do?
4. **Documentation of the `Viewport.push_input(event, true)` interaction with Control hit-testing.** The crawl told us push_input is GUI-routed but our test showed motion events delivered with non-local positions. There's a subtlety here that wasn't covered.

## Sources

- Original recipe — [`research/tools/godot-drag-drop-api.md`](../research/tools/godot-drag-drop-api.md) §3 (Recipe A)
- Confirmation Recipe A is current — [`research/tools/godot-4.6-drag-test-current-intel.md`](../research/tools/godot-4.6-drag-test-current-intel.md)
- The script-injection issue we hit isn't documented anywhere we found in the crawl. Worth posting to GUT issues / Godot forums after the overnight crawl confirms it's not common knowledge.
