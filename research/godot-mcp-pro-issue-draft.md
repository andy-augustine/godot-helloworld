# Draft GitHub issue for godot-mcp-pro — FILED 2026-04-26

> **Status:** filed and PR opened.
>
> - Issue: https://github.com/youichi-uda/godot-mcp-pro/issues/24
> - PR: https://github.com/youichi-uda/godot-mcp-pro/pull/25 (linked via `Closes #24`)
> - Fork branch: https://github.com/andy-augustine/godot-mcp-pro/tree/fix/synthetic-drag-gui-routing
> - Local fork clone: `/Users/claudeprojectlt8/code/personal/godot-mcp-pro-fork`
>
> Kept as a record of the body that was filed. Not a working draft anymore — edit the live issue / PR if anything needs to change.

**Tracker:** https://github.com/youichi-uda/godot-mcp-pro/issues/new

Two related items in one issue: a bug + an undocumented gotcha. Both surfaced while building automated tests for a Godot 4.6 Control drag-and-drop UI.

---

## Title

Synthetic drag-and-drop tests can't reach `_gui_input`: `unhandled` auto-promotion on `button_mask>0` motions + undocumented `relative` requirement

## Body

### Summary

While trying to write automated tests for a `Control` drag-and-drop UI in Godot 4.6.2, two issues in godot-mcp-pro (v1.12.0) made the canonical Recipe A pattern (`InputEventMouseButton` press → `InputEventMouseMotion` × N → release) silently fail end-to-end. Both have small, low-risk fixes.

### Bug 1: `_simulate_mouse_move` and `_dispatch_event` ignore explicit `unhandled: false`

**Where**: `addons/godot_mcp/commands/input_commands.gd:_simulate_mouse_move` and `addons/godot_mcp/mcp_input_service.gd:_dispatch_event`.

**What happens**: For `simulate_mouse_move` and `simulate_sequence` events of type `mouse_motion` with `button_mask > 0`, both layers unconditionally promote the event to `unhandled = true`, dispatching via `Viewport.push_input(event, true)`. This was clearly intended for the camera-pan use case (where a UI overlay would consume drag events). But it makes synthetic drag-and-drop testing of Control GUIs impossible — the events skip the GUI dispatcher's hit-test entirely, so `_get_drag_data` / `_can_drop_data` / `_drop_data` never fire on the right Controls. Even passing `unhandled: false` explicitly is silently overridden.

**Repro** (paraphrased):

```js
// JSON sent to simulate_sequence — should drive a real GUI drag end-to-end
{
  "frame_delay": 2,
  "events": [
    { "type": "mouse_button", "button": 1, "pressed": true,  "x": 832, "y": 192, "button_mask": 1, "unhandled": false },
    { "type": "mouse_motion",                                "x": 838, "y": 170, "relative_x": 6, "relative_y": -22, "button_mask": 1, "unhandled": false },
    // ... more motions ...
    { "type": "mouse_button", "button": 1, "pressed": false, "x": 867, "y": 73,  "button_mask": 0, "unhandled": false }
  ]
}
```

Expected: motions go through `Input.parse_input_event` → GUI dispatch → `_get_drag_data` fires on source Control, `_drop_data` fires on target.

Actual (without patch): motion events with `button_mask=1` get auto-promoted to `unhandled=true` regardless of the user-passed value, dispatched via `push_input(event, true)`. GUI hit-test is bypassed; drag never engages.

**Fix** (two-file diff):

`addons/godot_mcp/commands/input_commands.gd`:

```gdscript
# In _simulate_mouse_move, replace:
var unhandled: bool = optional_bool(params, "unhandled", false)
# ...
if unhandled or button_mask > 0:
    event["unhandled"] = true

# With:
var unhandled_explicit: bool = params.has("unhandled")
var unhandled: bool = optional_bool(params, "unhandled", false)
# ...
if unhandled_explicit:
    event["unhandled"] = unhandled
elif button_mask > 0:
    event["unhandled"] = true
```

`addons/godot_mcp/mcp_input_service.gd`:

```gdscript
# In _dispatch_event, replace:
var force_unhandled: bool = event_data.get("unhandled", false)
if not force_unhandled and event is InputEventMouseMotion and event.button_mask != 0:
    force_unhandled = true

# With:
var force_unhandled: bool
if event_data.has("unhandled"):
    force_unhandled = bool(event_data.get("unhandled"))
else:
    force_unhandled = event is InputEventMouseMotion and event.button_mask != 0
```

In both cases the **default behavior is preserved** when no `unhandled` key is provided — camera-pan use case keeps working. The change only affects callers who explicitly pass `unhandled: false`, which is the GUI drag-test case.

### Bug 2 (or doc gap): `relative_x` / `relative_y` are required for drag detection — undocumented

Even with bug 1 fixed and events reaching `_gui_input` correctly, drag-detection won't engage if motion events have `relative=(0,0)`. Godot's drag-detection threshold (~8 px) is computed against the *cumulative `relative`* on `InputEventMouseMotion`, not against absolute position deltas across consecutive motions. With `relative_x: 0, relative_y: 0` on every motion (which is the default if you only pass `x`/`y`), the threshold is never exceeded and `_get_drag_data` is never called.

This is undocumented in the `simulate_mouse_move` and `simulate_sequence` tool descriptions. The fix is just a documentation update — change the `relative_x` / `relative_y` parameter docs to make clear that:

- For drag testing, these MUST be non-zero on every motion event between press and release.
- Set them to the delta from the previous position (e.g., previous (832, 192) → next (838, 170) → `relative_x: 6, relative_y: -22`).

The tool already accepts these values; the gotcha is just that they default to 0, which silently disables drag detection.

### Why this matters

Without these fixes, `simulate_sequence` and `simulate_mouse_move` cannot be used to test any UI built on Godot's `Control._get_drag_data` / `_drop_data` system — inventories, card games, tile/tilesheet editors, file browsers, etc. Manual playtest is the only validation. With the fixes, the canonical Recipe A pattern works end-to-end and an entire category of UI test becomes automatable.

I have a working test harness against a real Control drag-and-drop UI (a skill-card inventory in a Godot 4.6.2 platformer) that confirms the fix and documents the recipe. Happy to share if useful.

### Environment

- Godot 4.6.2-stable
- godot-mcp-pro v1.12.0
- macOS

### Bonus / aside (not blocking the bug fix)

Separate issue we observed but couldn't isolate: `Input.parse_input_event(event)` and `Viewport.push_input(event)` called from inside `execute_game_script` don't reach `_gui_input` on Controls — the events update polled state (`Input.get_mouse_button_mask()` is correctly set) but never trigger Control hit-testing. The MCP `simulate_*` tools (which dispatch from the addon's `_process` context) work fine. Only mention it in case it's a known issue or rings a bell — it's an annoyance for inline-script-driven tests but the workaround is "use the MCP tools".

---

## Notes for filing

- Copy the body above into https://github.com/youichi-uda/godot-mcp-pro/issues/new.
- Title field: keep the title above as-is.
- Body field: everything from "Summary" through "## Bonus" goes into the body (markdown supported).
- The Environment section is intentionally minimal. If the maintainer asks for hardware/repo/repro project, respond at that point — don't volunteer it upfront.
