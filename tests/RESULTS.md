# Drag-recipe validation results

| | |
|---|---|
| Validated | 2026-04-26 (multiple iterations, ending in working recipe) |
| Godot version | 4.6.2-stable (official, hash `71f334935`) |
| Runner | `tests/run_drag_recipe.gd` (direct + synthetic modes) |
| Companion docs | [`research/tools/godot-4.6-drag-test-current-intel.md`](../research/tools/godot-4.6-drag-test-current-intel.md), [`TESTING.md`](../TESTING.md) Pattern 4 |

## TL;DR — synthetic drag works in Godot 4.6.2 via godot-mcp-pro

**End-to-end synthetic drag IS achievable through the godot-mcp-pro `simulate_*` tools, after two small local addon patches. The single missing piece was the `relative` field on motion events** — Godot's drag-detection accumulates `relative` deltas to compare against the ~8 px drag threshold. With `relative=(0,0)` on every motion, the threshold is never exceeded. With proper `relative_x`/`relative_y` populated to match the position deltas, the drag state machine engages, `_get_drag_data` fires, `_drop_data` runs, state mutates correctly. Verified 2026-04-26: `Skills.active=turbo, speed_mult=1.5, drag_ok=true` post-drag; cards reorganized as expected.

## The working recipe

Two equivalent forms, both verified end-to-end:

### Form A — single `simulate_sequence` call (preferred)

```jsonc
{
  "frame_delay": 2,
  "events": [
    { "type": "mouse_button", "button": 1, "pressed": true,
      "x": 832, "y": 192, "button_mask": 1, "unhandled": false },
    { "type": "mouse_motion", "x": 838, "y": 170,
      "relative_x": 6, "relative_y": -22,
      "button_mask": 1, "unhandled": false },
    { "type": "mouse_motion", "x": 845, "y": 145,
      "relative_x": 7, "relative_y": -25,
      "button_mask": 1, "unhandled": false },
    // ... more motions with non-zero relative ...
    { "type": "mouse_motion", "x": 867, "y": 73,
      "relative_x": 8, "relative_y": -22,
      "button_mask": 1, "unhandled": false },
    { "type": "mouse_button", "button": 1, "pressed": false,
      "x": 867, "y": 73, "button_mask": 0, "unhandled": false }
  ]
}
```

Then wait via `Bash sleep 1.0` and read final state.

### Form B — multiple individual MCP calls (fallback)

`simulate_mouse_click(x, y, button=1, pressed=true, auto_release=false)` for press, `simulate_mouse_move(x, y, relative_x=..., relative_y=..., button_mask=1, unhandled=false)` for each motion, `simulate_mouse_click(x, y, button=1, pressed=false, auto_release=false)` for release. Several round-trips, but each one reaches GUI dispatch reliably.

### Critical gotchas

1. **`relative` MUST be non-zero on motions.** Without it, drag-detection threshold accumulates 0 forever. The most expensive thing to debug because all the visible event data looks correct otherwise.
2. **`unhandled: false` MUST be explicitly set on motion events** (the default auto-promotes button_mask>0 motions to `push_input(event, true)`, which interferes with normal GUI hit-testing). Requires the local addon patches in `addons/godot_mcp/commands/input_commands.gd` and `addons/godot_mcp/mcp_input_service.gd`.
3. **Position is in viewport coords** (e.g., 0–960, 0–540 for our project), NOT window pixels. Window is 1920×1018; positions are still in 960×540 space.
4. **Use `frame_delay >= 1`** for `simulate_sequence` so events spread across frames. The drag state machine needs at least one frame between press and threshold-exceeding motion.
5. **Don't try `Input.parse_input_event` from inside `execute_game_script`** — events update the polled state but don't reach `_gui_input` for some reason (this remains an unsolved mystery, but it doesn't matter because the MCP tools work).

## What we patched

Two local addon patches (license-allowed local-only modifications):

### `addons/godot_mcp/commands/input_commands.gd`

`_simulate_mouse_move()` no longer unconditionally sets `unhandled: true` when `button_mask > 0`. Instead, it honors the caller's explicit value if one was passed (using `params.has("unhandled")` to detect explicit-vs-default). Default behavior preserved when caller doesn't pass `unhandled`.

### `addons/godot_mcp/mcp_input_service.gd`

`_dispatch_event()` similarly honors explicit `unhandled: false` instead of unconditionally auto-promoting motions with `button_mask > 0`. Both layers needed — the first patch determines the value written to the event payload; the second determines how `_dispatch_event` interprets it at dispatch time.

## What works ✅

1. **Synthetic drag end-to-end** — equip, swap, deactivate via `simulate_sequence` or chained `simulate_*` calls. Validated by `tests/run_drag_recipe.gd` synthetic mode.
2. **Direct method invocation** — `target_slot._can_drop_data(pos, data)` + `target_slot._drop_data(pos, data)` from `execute_game_script`. Faster than synthetic for slot-logic regression tests; doesn't exercise hit-test or state-machine paths.
3. **Polled mouse state updates** from `Input.parse_input_event` (sets `Input.get_mouse_button_mask()` correctly).
4. **MCP `simulate_mouse_click`** triggers `_gui_input` correctly (basis for the synthetic recipe).

## What still doesn't work ❌

1. **`Input.parse_input_event` / `Viewport.push_input` from inside `execute_game_script`** still don't trigger `_gui_input` on Controls. Root cause unknown — likely a `_cmd_execute_script` runtime-context scheduling issue. **No workaround found in this session, but it doesn't matter** because the MCP plugin's `simulate_*` tools (which run from the addon's `_process` context) work correctly.
2. **`Control.force_drag(data, preview)` + synthetic release** — confirmed by-design dead-end. Don't try.
3. **`Input.warp_mouse(pos)`** takes window pixels (NOT viewport coords). For viewport coord (X, Y) → warp to window (X * window_w/viewport_w, Y * window_h/viewport_h). Mostly irrelevant since the synthetic recipe doesn't need to move the cursor — Godot's drag system tracks position from the event stream, not the OS cursor.

## Observed runner output — 2026-04-26 final pass

### Synthetic mode (turbo equip)

```
ready. active=- | inv1=turbo | inv2=high_jump
[simulate_sequence with relative on motions, unhandled:false]
post: active=turbo | speed_mult=1.5 | drag_ok=true
slots: inv1=high_jump | inv2=- | active.card=turbo
```

### Direct mode (all four scenarios + 2 negative controls)

```
baseline: active=- | inv1=turbo | inv2=high_jump | speed=1.0 | jump=1.0
mode1 (equip turbo): can_drop=true
after mode1: active=turbo | inv1=high_jump | inv2=- | speed=1.5
mode2 (swap to high_jump): can_drop=true
after mode2: active=high_jump | inv1=turbo | jump=1.5
mode3 (deactivate): can_drop=true
after mode3: active=- | inv1=turbo | inv2=high_jump
mode4 (inv1→inv2 reject): can_drop=false (expect false)
mode4b (inv1→inv1 reject): can_drop=false (expect false)
```

All modes pass, both negative controls reject correctly.

## What this means for the planned skill

**The "synthetic drag-and-drop test" Claude skill DOES graduate, with caveats.** The synthetic recipe works end-to-end against a real `Control` GUI in Godot 4.6.2 via the godot-mcp-pro tools — but only after the local addon patches and only with the `relative` field correctly populated on every motion. A skill that automates this pattern is now feasible:

- The skill would emit a `simulate_sequence` JSON with positions stepped from source to target and `relative_x`/`relative_y` computed as deltas.
- The skill should warn if the target project hasn't applied the addon patches.
- The skill must set `unhandled: false` on every motion.

This is a meaningful unlock — automated UI drag-testing was previously something we'd have categorized as "manual playtest only".

## Open follow-ups (not blocking)

- Reproduce on a *vanilla* godot-mcp-pro install (without our patches) and propose the patches upstream as a bug fix — the auto-promotion of `unhandled` on `button_mask>0` motions is genuinely wrong for GUI drag testing, and the second-layer patch in `_simulate_mouse_move` was clearly an after-the-fact attempt to fix `simulate_mouse_move` for camera-pan use cases that broke drag testing as a side effect.
- Document the `relative` requirement upstream too — it's an undocumented gotcha for anyone trying to use simulate_sequence for drag testing.
- The `Input.parse_input_event` from `execute_game_script` not reaching `_gui_input` is still a mystery worth chasing in the overnight crawl.

## Sources

- Original recipe — [`research/tools/godot-drag-drop-api.md`](../research/tools/godot-drag-drop-api.md) §3 (Recipe A)
- Targeted research crawl — [`research/tools/godot-4.6-drag-test-current-intel.md`](../research/tools/godot-4.6-drag-test-current-intel.md)
- godot-mcp-pro source (locally extracted) — `/Users/claudeprojectlt8/code/tools/godot-mcp-pro/115334_godotmcpprov1.12.0/addons/godot_mcp/`
