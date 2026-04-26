# Drag-recipe validation results

| | |
|---|---|
| Validated | 2026-04-26 |
| Godot version | 4.6.2-stable (official, hash `71f334935`) |
| Runner | `tests/run_drag_recipe.gd` |
| Project SHA | (top of `main` at validation time) |

## Headline finding — synthetic drag is broken in Godot 4.6.2

**The canonical "Recipe A" from `research/tools/godot-drag-drop-api.md §3` does not work in Godot 4.6.2 for testing UI Control drag-and-drop.**

Empirical evidence collected during P5:

1. **`Input.parse_input_event(InputEventMouseButton)` does not trigger `_gui_input`** on the topmost Control under the press position. Verified by hooking a counter to `card.gui_input` signal, dispatching a synthetic press, then reading the counter — fires 0 times immediately and 0 times after a 300 ms wait.
2. **`Viewport.push_input(event)` also does not trigger `_gui_input`** for synthetic events. Same counter test, same result.
3. **`Control.force_drag(data, preview)` does engage the drag** (`gui_is_dragging=true`, `gui_get_drag_data` returns the data), but synthetic release events do NOT trigger `_drop_data` on the target. The drag silently ends after a delay with `gui_is_drag_successful=false` and no state change.

Because `_gui_input` never fires for synthetic input, the GUI dispatcher never registers a "potential drag" from the source Control, so neither `_get_drag_data` nor `_drop_data` ever fires from a synthetic event sequence. The recipe's `button_mask`, `use_accumulated_input`, and frame-pacing details are all moot — the events don't reach the GUI at all.

This may have changed since the recipe was written. The recipe was based on:
- Godot 4 stable docs (which indicate `parse_input_event` should reach `_input`/`_gui_input`/`_unhandled_input`)
- GUT issue #608 (May 2024) where synthetic drag testing did work, with `button_mask` as the gotcha
- Generic 4.x community knowledge

Either Godot 4.6 introduced a regression or the recipe was always more fragile than it appeared. The exact cause hasn't been bisected — that's a follow-up if it matters.

## What works — direct `_drop_data` invocation

Bypass synthetic input entirely. Get the source slot's card data, get the target slot, call `target._can_drop_data(pos, data)` to verify acceptance, then `target._drop_data(pos, data)` to execute the drop. The slot's logic + `Skills.set_active` + `SkillsPanel._rebuild` chain all run synchronously and correctly.

This is a **unit test of the slot drop-handling logic, not an end-to-end drag test**. It catches regressions in:
- `_can_drop_data` predicate (accepts valid drops, rejects invalid)
- `_drop_data` state mutation (Skills.set_active called correctly)
- Position-aware swap behavior (rebuild reorders cards as expected)
- Multipliers reaching the player (verified via `Skills.get_speed_multiplier()`)

It does NOT catch:
- Mouse-filter regressions (events not reaching the right Control)
- Drag preview rendering issues
- Drag threshold / hit-test issues
- Anything that requires real OS mouse events going through GUI dispatch

For those, manual playtest by the user is the only validation.

## Observed output — 2026-04-26

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

All four positive modes succeed. Both negative-control rejections succeed.

## What this means for the planned skill

**The "synthetic drag-and-drop test" Claude skill we set out to build does not graduate.** The recipe it would have packaged doesn't work in current Godot. Capturing the empirical finding here is the deliverable instead.

What replaces it: this runner (`tests/run_drag_recipe.gd`) as a project-local regression test, plus a TESTING.md "Pattern 4" entry documenting the direct-invocation pattern + the synthetic-drag dead-end so future Claude sessions don't burn cycles trying it again.

## Open follow-ups (not blocking)

- **Bisect** when synthetic drag broke. If it works in Godot 4.5 or earlier, the issue is a 4.6 regression worth filing upstream. (Not done — out of scope for this build.)
- **Try GUT's `InputSender`** — they had it working in Godot 4.x at some point; their helper might wrap something we're missing. (Not tried.)
- **`Engine.singleton_get("DisplayServer")` / `DisplayServer.simulate_*`** — there may be a lower-level injection point. (Not investigated.)
- **`Input.action_press` does NOT help here** — actions don't include mouse position; drag needs spatial events.
