# Godot 4 drag-and-drop API — research notes

| | |
|---|---|
| Scope | Godot 4 native APIs for driving / testing drag-and-drop from script |
| Researched | 2026-04-26 |
| Pairs with | [`../../TESTING.md`](../../TESTING.md) — MCP async-latency pattern |

## ⚠️ Update 2026-04-26 — empirical finding

**Recipe A below does NOT work in Godot 4.6.2.** Verified end-to-end against the real `SkillsPanel` UI in this project (see `tests/RESULTS.md`). Concrete observations:

- `Input.parse_input_event(InputEventMouseButton)` and `Viewport.push_input(event)` both fail to trigger `_gui_input` on the topmost Control under the press position. Hooked a counter to `card.gui_input` signal — fires 0 times immediately and 0 times after a 300 ms wait.
- Because `_gui_input` never fires, the GUI dispatcher never registers a "potential drag" from the source. Subsequent motion events past threshold do not call `_get_drag_data`. The recipe's `button_mask` / `use_accumulated_input` / frame-pacing details are all moot — the events don't reach GUI dispatch at all.
- `Control.force_drag(data, preview)` *does* engage the drag (`gui_is_dragging` → true, `gui_get_drag_data()` returns the payload), but synthetic release events do NOT trigger `_drop_data` on the target. The drag silently ends after a delay with `gui_is_drag_successful=false` and no state mutation.

This may be a Godot 4.6 regression vs. earlier 4.x. GUT issue #608 (May 2024) documented synthetic drag working with `button_mask` as the gotcha. We did not bisect when the regression landed.

**What works instead** for testing UI Control drag-and-drop in Godot 4.6: directly invoke `target_slot._can_drop_data(pos, data)` and `target_slot._drop_data(pos, data)` from `execute_game_script`. This is a unit test of the slot logic — it does NOT exercise the GUI hit-test path or the engine's drag state machine. It catches regressions in slot routing rules but not in mouse-filter / hit-test / preview rendering. For those, manual playtest is the only option. See `tests/run_drag_recipe.gd` for the runner and `tests/RESULTS.md` for observed output.

The recipe and discussion below are kept as-is for historical reference and in case the underlying behavior changes back. **Do not extract them into a Claude skill in their current form** — they will produce silent test passes that don't actually validate drag.

---

## Verdict (original — superseded by the update above for Godot 4.6.2)

**Conditional yes.** Godot has a clean API for synthesizing drag (`Input.parse_input_event` + `InputEventMouseButton` + `InputEventMouseMotion`), but the **non-obvious gotcha is `button_mask`** on the motion events. Without it, Godot's GUI dispatcher doesn't recognize a held button, so `_can_drop_data` / drag-preview never fires. The GUT issue #608 thread documents this exact failure mode and the fix.

Top recommendation: use **Pattern 1** from `TESTING.md` (single `execute_game_script` call with internal `await get_tree().physics_frame` loop). Inside that, build `InputEventMouseButton`/`InputEventMouseMotion` manually with `button_mask = MOUSE_BUTTON_MASK_LEFT` on every motion event, set `Input.use_accumulated_input = false` for the duration, and feed them through `Input.parse_input_event(...)`. The full recipe is in section 3.

A `simulate_drag(from, to, steps)` MCP tool would be a thin wrapper around exactly that recipe. Worth adding to godot-mcp-pro.

## 1. Two flavors of drag-and-drop in Godot

### Flavor A — Control-node UI drag-and-drop (built-in)

Godot's GUI system has first-class drag-and-drop between `Control` nodes. The application defines three virtual methods; the engine drives the lifecycle.

**Lifecycle (engine-driven):**

1. User mouse-presses on a `Control` whose `mouse_filter` is not `IGNORE`.
2. User moves the mouse past the drag threshold (project setting `gui/common/snap_controls_to_pixels`-adjacent behaviour, ~8 px default).
3. Godot calls `_get_drag_data(at_position)` on the source Control. Return a non-`null` Variant to start the drag; return `null` to abort.
4. While dragging, Godot continuously calls `_can_drop_data(at_position, data)` on **whichever Control is under the mouse** each frame.
5. Source Control's `set_drag_preview(control)` (typically called inside `_get_drag_data`) installs a Control that follows the mouse.
6. On mouse-release: if `_can_drop_data` returned `true`, Godot calls `_drop_data(at_position, data)` on the target. Otherwise drag is cancelled.
7. The preview node is auto-freed (Godot connects to its `tree_exiting`).

**Canonical source-side code:**

```gdscript
func _get_drag_data(at_position: Vector2) -> Variant:
    var item := inventory.item_at(at_position)
    if item == null: return null
    var preview := _create_item_preview(item)   # any Control
    set_drag_preview(preview)                    # makes preview a child of self
    return { "source": self, "item": item }      # any Variant works as drag data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    return data is Dictionary and data.has("item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
    inventory.add_item_at(data.item, at_position)
    if data.source: data.source.remove_item(data.item)
```

**Programmatic / observer hooks:**

| API | Purpose |
|---|---|
| `Control.force_drag(data, preview)` | Start a drag without going through `_get_drag_data`. Useful to skip the threshold + click. **Known bug in 4.3:** preview not always updated (godot#107128). |
| `Control.set_drag_forwarding(get_fn, can_fn, drop_fn)` | Forward the three callbacks to `Callable`s instead of overriding methods (good for composition). |
| `Viewport.gui_is_dragging() -> bool` | True between drag-start and drop. |
| `Viewport.gui_get_drag_data() -> Variant` | Inspect the in-flight drag payload. |
| `Viewport.gui_is_drag_successful() / Control.is_drag_successful()` | True if the most recent drag ended with a `_drop_data` call. |
| `Control.set_drag_preview(control)` | Install the preview that follows the cursor. Auto-removed on drag end. |

No drag-specific signals — observation is via the polling methods above or by overriding `_drop_data`.

### Flavor B — Custom drag of a 2D node (sprite, RigidBody2D, Node2D)

Plain user code, no engine drag system involved. Pattern: track a `held` boolean, listen for press/release on the body, and follow the mouse while held.

**Canonical pattern (from kidscancode 4.x recipe, RigidBody2D):**

```gdscript
extends RigidBody2D

var held: bool = false

func _on_input_event(_viewport, event, _shape_idx) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        pickup()

func _physics_process(_delta: float) -> void:
    if held:
        global_position = get_global_mouse_position()

func pickup() -> void:
    freeze = true       # for RigidBody2D; for CharacterBody2D / Node2D, just set held = true
    held = true

func drop(impulse: Vector2 = Vector2.ZERO) -> void:
    freeze = false
    apply_central_impulse(impulse)
    held = false
```

A scene-level handler watches for release globally so the drop fires even if the cursor leaves the body:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        if held_object:
            held_object.drop(Input.get_last_mouse_velocity())
            held_object = null
```

**Events that fire (by handler):**

- On `Area2D` / `RigidBody2D` with `input_pickable = true`: `input_event(viewport, event, shape_idx)` signal — used above.
- On any node: `_input(event)` — global, fires before GUI processing.
- On a `Control` under the mouse: `_gui_input(event)` — already pre-filtered for bounds + `mouse_filter`.
- Anywhere: `_unhandled_input(event)` — only events nothing else consumed.

## 2. Programmatic input injection (the testing primitive)

### `Input.parse_input_event(event)`

The canonical synthetic-input entry point. Feeds the event into the same pipeline as a real OS event:

- Reaches `_input()`, `_gui_input()`, `_unhandled_input()` in normal order (depth-first reverse-tree, then GUI, then unhandled).
- Does **not** touch the OS cursor.
- Has no return value; success is implicit.

Per docs: *"Calling this function has no influence on the operating system."* The event is processed on the **next frame's input dispatch**, not synchronously — so an `await get_tree().process_frame` (or `physics_frame`) is required between events for them to be observed.

### `Input.warp_mouse(position)`

Teleports the OS cursor to a window-relative pixel position. Critically:

- **Does NOT generate an `InputEventMouseMotion`.** It just moves the cursor. Drag listeners that watch for motion events will see nothing.
- Windows / macOS / Linux only — no-op on web/mobile.
- Position is clipped to the window unless mouse mode is `MOUSE_MODE_CAPTURED`.

For testing drag, use `parse_input_event(InputEventMouseMotion)` instead — `warp_mouse` is for "place cursor here for visual reasons" only.

### `Input.action_press(action, strength=1.0)` / `Input.action_release(action)`

Updates the action-state cache (`Input.is_action_pressed("foo")` will return true). **Does NOT call `_input()`.** Useful for actions mapped to a button. **Useless for raw mouse drag** — drag is observed via the event stream, not via action polling. Confirmed.

### `InputEventMouseButton` field requirements

| Field | Required for drag synth? | Notes |
|---|---|---|
| `button_index` | **Yes** | `MOUSE_BUTTON_LEFT` etc. Without it, GUI dispatcher ignores the event. |
| `pressed` | **Yes** | Distinguishes press from release. |
| `position` | **Yes** | Local viewport coordinates. GUI uses this to find the target Control. |
| `global_position` | Recommended | Should equal `position` in single-window setups. |
| `button_mask` | Recommended | Bitmask of currently-held buttons. Set after press, cleared on release. |
| `double_click` | No | Defaults false. |
| `factor`, `canceled` | No | Special-purpose. |

### `InputEventMouseMotion` field requirements

| Field | Required for drag synth? | Notes |
|---|---|---|
| `position` | **Yes** | Where the cursor "is" after the motion. |
| `global_position` | Recommended | Match `position`. |
| `relative` | **Yes for drag** | `position - previous_position`. Many drag handlers (custom Flavor-B code) use only `relative`, not absolute. |
| `button_mask` | **CRITICAL for drag** | **Must be `MOUSE_BUTTON_MASK_LEFT` (or appropriate mask) while button is held.** Godot's GUI drag dispatcher checks this to know a drag is in progress. **This is the #1 reason synthetic drag tests silently fail.** |
| `velocity` | Optional | Pixels/sec. Drop code may inspect it (`Input.get_last_mouse_velocity()`). |
| `screen_relative`, `screen_velocity` | Optional | Unscaled equivalents (4.4+). |
| `pressure`, `tilt`, `pen_inverted` | Optional | Stylus only. |

### `Input.use_accumulated_input`

Default `true` — Godot batches motion events to one per rendered frame. **For synthetic drag testing, set to `false`** (either via `Input.use_accumulated_input = false` for the duration, or `await get_tree().process_frame` between every motion event). Otherwise the GUI dispatcher merges your N stepped motion events into one big jump and the drag system sees only the final position.

Godot proposal #73543 documents that this property is somewhat finicky in practice; the safe pattern is to also `await physics_frame` between motion events.

### `--write-movie` CLI flag

Godot 4 Movie Maker mode. Renders deterministically by setting a fixed delta:

```
godot --path /path/to/project --write-movie out.avi --fixed-fps 60 --quit-after 600
```

- Output formats: AVI (MJPEG + uncompressed PCM), OGV (Theora + Vorbis), or PNG sequence + WAV.
- `--fixed-fps N` makes `delta` constant; rendering speed decouples from real time.
- `--quit-after N` exits after N frames.
- **User input is still received during recording** — and so is `Input.parse_input_event`. This is the canonical way to make a deterministic playtest video.
- The docs do not explicitly guarantee determinism for synthetic input + Movie Maker, but the `--fixed-fps` design implies it: same input sequence + same fps → same frames.

For our use case (verifying drag inside an `execute_game_script` call), Movie Maker is overkill. Save PNGs from inside the script: `get_viewport().get_texture().get_image().save_png("res://qa/step_%d.png" % i)`.

## 3. The drag canonical recipe

Both forms below are designed to drop directly into a single `execute_game_script` call. They follow Pattern 1 from `TESTING.md`: wrap awaiting logic in a lambda, await it once, log results.

### Recipe A — Synthetic UI drag-and-drop (Control flavor)

```gdscript
# Inputs:
var SOURCE_PATH := "/root/World/Inventory/SlotA"   # NodePath to draggable Control
var FROM_POS    := Vector2(64, 64)                 # screen-space pixel
var TO_POS      := Vector2(320, 200)               # screen-space pixel
var STEPS       := 12                              # motion steps from→to
var FRAMES_PER_STEP := 2                           # physics frames between motions

var src: Control = get_tree().root.get_node(SOURCE_PATH)
var prev_accum := Input.use_accumulated_input
Input.use_accumulated_input = false   # CRITICAL: don't merge our motion events

var results := []

var run := func() -> void:
    # 1. Press at FROM_POS
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.pressed = true
    press.position = FROM_POS
    press.global_position = FROM_POS
    press.button_mask = MOUSE_BUTTON_MASK_LEFT
    Input.parse_input_event(press)
    await get_tree().process_frame

    # 2. Step from FROM_POS toward TO_POS, set button_mask on every motion event
    var prev := FROM_POS
    for i in STEPS:
        var t := float(i + 1) / float(STEPS)
        var pos := FROM_POS.lerp(TO_POS, t)
        var move := InputEventMouseMotion.new()
        move.position = pos
        move.global_position = pos
        move.relative = pos - prev
        move.velocity = (pos - prev) / get_physics_process_delta_time()
        move.button_mask = MOUSE_BUTTON_MASK_LEFT   # CRITICAL — without this the drag never starts
        Input.parse_input_event(move)
        prev = pos
        for _f in FRAMES_PER_STEP:
            await get_tree().physics_frame
        # observation: is Godot's drag system live?
        if i == 1:
            results.append("after step 2: gui_is_dragging=%s drag_data=%s" % [
                get_viewport().gui_is_dragging(),
                str(get_viewport().gui_get_drag_data())
            ])

    # 3. Release at TO_POS
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    release.position = TO_POS
    release.global_position = TO_POS
    release.button_mask = 0
    Input.parse_input_event(release)
    await get_tree().process_frame

    results.append("post-release: gui_is_dragging=%s drag_successful=%s" % [
        get_viewport().gui_is_dragging(),
        get_viewport().gui_is_drag_successful()
    ])

await run.call()

Input.use_accumulated_input = prev_accum
for line in results:
    _mcp_print(line)
```

### Recipe B — Synthetic custom-physics drag (Flavor B sprite)

For a sprite/Node2D that follows the mouse while held. Same input synthesis; we observe the node's `global_position` instead of viewport drag state.

```gdscript
var SPRITE_PATH := "/root/World/Pickups/Box"
var FROM_POS    := Vector2(150, 400)
var TO_POS      := Vector2(700, 200)
var STEPS       := 16
var FRAMES_PER_STEP := 2

var sprite: Node2D = get_tree().root.get_node(SPRITE_PATH)
sprite.global_position = FROM_POS   # park it at the start so the press hits it

var prev_accum := Input.use_accumulated_input
Input.use_accumulated_input = false

var results := []

var run := func() -> void:
    # 1. Press
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.pressed = true
    press.position = FROM_POS
    press.global_position = FROM_POS
    press.button_mask = MOUSE_BUTTON_MASK_LEFT
    Input.parse_input_event(press)
    await get_tree().process_frame
    results.append("after press: sprite=%s" % sprite.global_position)

    # 2. Motion
    var prev := FROM_POS
    for i in STEPS:
        var t := float(i + 1) / float(STEPS)
        var pos := FROM_POS.lerp(TO_POS, t)
        var move := InputEventMouseMotion.new()
        move.position = pos
        move.global_position = pos
        move.relative = pos - prev
        move.button_mask = MOUSE_BUTTON_MASK_LEFT
        Input.parse_input_event(move)
        prev = pos
        for _f in FRAMES_PER_STEP:
            await get_tree().physics_frame

    results.append("mid-drag: sprite=%s (target=%s)" % [sprite.global_position, TO_POS])

    # 3. Release
    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    release.position = TO_POS
    release.global_position = TO_POS
    release.button_mask = 0
    Input.parse_input_event(release)
    await get_tree().process_frame
    results.append("after release: sprite=%s" % sprite.global_position)

await run.call()

Input.use_accumulated_input = prev_accum
for line in results:
    _mcp_print(line)
```

### Why the recipes work where naïve attempts fail

Three things kill naïve drag tests:

1. **`button_mask = 0` on motion events** → engine doesn't see a held button → no drag. Fix: set `MOUSE_BUTTON_MASK_LEFT` on every `InputEventMouseMotion` between press and release.
2. **Input accumulation merging the steps into one event** → the test looks like a teleport, not a drag. Fix: `Input.use_accumulated_input = false` plus `await physics_frame` between motions.
3. **Multiple separate MCP calls** → game advances ~30 physics frames between calls, drag threshold blown past, preview gone before observation. Fix: do the whole sequence inside one `execute_game_script`.

This was the exact root cause documented in [GUT issue #608](https://github.com/bitwes/Gut/issues/608) — the original reporter hit (1) with `InputSender.mouse_relative_motion` (which omitted `button_mask`); the workaround was to build the `InputEventMouseMotion` manually with `event.button_mask = MOUSE_BUTTON_MASK_LEFT`.

## 4. Godot's own testing tools

### GUT (Godot Unit Test) — bitwes/Gut

The mainline Godot unit-test framework. As of issue #608 (May 2024), `InputSender.mouse_relative_motion` did not set `button_mask`, so out-of-the-box GUT could not test built-in Control drag-and-drop. PRs #612 / #613 are listed as "in next release" — verify against the current GUT version before relying on it. Workaround inside GUT: build motion events with `InputFactory.mouse_motion(pos)` and set `event.button_mask = MOUSE_BUTTON_MASK_LEFT` manually.

GUT is opinionated about test lifecycle (`before_all`, `after_each`, etc.) which is heavier than what we need from `execute_game_script`. Adoption verdict: not necessary for our MCP-driven flow; the recipes above are GUT-free.

### GodotTestDriver — chickensoft-games

C#-only library with a `viewport.DragMouse(from, to)` extension. Implementation likely uses the same `parse_input_event` pattern (we couldn't find the source file in fetched docs to verify — implementation lives in `GodotTestDriver/Input/MouseExtensions.cs`). C# requirement makes it a non-starter for this GDScript project, but it confirms the API surface is real and reusable.

### Built-in pacing primitives

| API | Use |
|---|---|
| `await get_tree().process_frame` | Wait one rendered frame. |
| `await get_tree().physics_frame` | Wait one physics tick (60 Hz default). Preferred between input events for deterministic observation. |
| `Engine.time_scale` | Multiplier (1.0 default). Set to 0.1 to slow time for visual debugging; set to 5.0 to fast-forward a sequence. **Note:** affects `_process` delta but `physics_frame` ticks still fire on the same wall-clock cadence — using `time_scale` to "speed up" tests interacts oddly with input pacing. Prefer just running more steps. |
| `get_tree().paused` | Pause everything that doesn't have `process_mode = ALWAYS`. Good for "freeze and inspect" but stops `physics_frame` from firing — your `await` will hang. |
| `Engine.physics_ticks_per_second` | Default 60. Lowering = each frame more "drag distance" per step in our recipes. Don't change it for tests. |

## 5. Detection / observation

After injecting drag events, here's how to verify the drag actually worked:

| Check | API | What it tells you |
|---|---|---|
| Built-in drag state | `get_viewport().gui_is_dragging()` | True between `_get_drag_data` returning non-null and drop/cancel. |
| In-flight drag payload | `get_viewport().gui_get_drag_data()` | The Variant returned by `_get_drag_data`. Useful to confirm "drag of THIS item is live". |
| Drag-end success | `get_viewport().gui_is_drag_successful()` / `Control.is_drag_successful()` | True iff `_drop_data` was called (i.e. `_can_drop_data` accepted on release). |
| Custom-flavor position | `sprite.global_position` | For Flavor B, just read the node directly. |
| Drop-target side effects | Whatever your `_drop_data` mutates | E.g. inventory item count, child-node list. |
| Preview Control existence | Walk the source Control's children for the preview node | Lower-level, only if you need to assert the preview is visible. |

**Common assertion shape in `execute_game_script`:**

```gdscript
results.append("dragging=%s drop_ok=%s slot_count=%d" % [
    get_viewport().gui_is_dragging(),
    get_viewport().gui_is_drag_successful(),
    target_slot.get_child_count()
])
```

Then have the MCP layer parse the printed line.

## 6. Known gotchas

1. **`button_mask` on motion events.** Already covered. The number-one silent failure.
2. **Input accumulation merges steps.** Set `Input.use_accumulated_input = false` for the duration of the test.
3. **`warp_mouse` doesn't fire motion events.** Don't use it for drag — use `parse_input_event(InputEventMouseMotion)`.
4. **`Input.action_press` doesn't fire `_input`.** Only updates polled action state. Useless for mouse drag (which is event-driven).
5. **`MOUSE_FILTER_IGNORE` Controls swallow nothing — they're invisible to mouse events.** But `MOUSE_FILTER_STOP` (default for many Controls) **consumes** mouse events, so a transparent Control over your draggable will eat the press silently. Check the Control tree under your `FROM_POS`. `find_nodes_by_type` in MCP can help.
6. **Drag threshold.** Built-in drag-and-drop won't trigger until the cursor moves ~8px from press position. Ensure your first motion step exceeds this. (`force_drag()` bypasses the threshold but has the 4.3 preview bug.)
7. **`_input` runs before `_gui_input` runs before `_unhandled_input`.** If your top-level `_input` calls `get_viewport().set_input_as_handled()`, GUI drag never sees the event. Surprisingly easy to do this accidentally.
8. **Drag preview Control follows the mouse via the engine, not your code.** Synthesizing motion events at correct positions is sufficient — the preview will track. But if `force_drag` is used and preview doesn't appear (godot#107128 in 4.3), check Godot version.
9. **Mouse warping doesn't cross window boundaries.** Irrelevant for `parse_input_event` (which doesn't touch the OS cursor) but matters if a test tries to mix `warp_mouse` with synthetic events.
10. **Top-level `await` crashes `execute_game_script`.** Already documented in `TESTING.md`. Wrap awaiting code in a lambda.
11. **Press-release without intermediate motion doesn't drag.** Even with `button_mask` set, the GUI dispatcher needs at least one motion event past the threshold to commit to "this is a drag, not a click."
12. **Releasing without restoring `Input.use_accumulated_input`.** Persists across calls. Always restore it (the recipes do).

## What this implies for godot-mcp-pro

The plugin already has `simulate_mouse_click`, `simulate_mouse_move`, and `simulate_sequence`. None of those expose `button_mask` on motion events, and they're separate MCP calls (so the latency problem from `TESTING.md` applies).

A clean addition would be a single `simulate_drag(from: Vector2, to: Vector2, steps: int = 12, frames_per_step: int = 2, button: MouseButton = LEFT)` tool that, server-side, runs Recipe A's body inside one `execute_game_script` round-trip. That gives both flavors of drag (the same recipe drives Flavor B) in one synchronous call.

## Sources

- [Godot 4.x Drag-and-Drop — DEV Community (pdeveloper)](https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13)
- [Godot Control drag-and-drop example gist (PrestonKnopp)](https://gist.github.com/PrestonKnopp/b53752f08b5446ff248c8cfa58105c2b)
- [RigidBody2D Drag and Drop — Godot 4 Recipes (kidscancode)](https://kidscancode.org/godot_recipes/4.x/physics/rigidbody_drag_drop/index.html)
- [Input class reference — Godot 4 stable](https://docs.godotengine.org/en/stable/classes/class_input.html)
- [Control class reference — Godot 4 stable](https://docs.godotengine.org/en/stable/classes/class_control.html)
- [InputEventMouseMotion reference — Godot 4 stable](https://docs.godotengine.org/en/stable/classes/class_inputeventmousemotion.html)
- [InputEventMouseButton reference — Godot 4 stable](https://docs.godotengine.org/en/stable/classes/class_inputeventmousebutton.html)
- [Creating movies (--write-movie) — Godot 4 stable](https://docs.godotengine.org/en/stable/tutorials/animation/creating_movies.html)
- [GUT issue #608 — drag simulation thread (button_mask discovery)](https://github.com/bitwes/Gut/issues/608)
- [GodotTestDriver — chickensoft-games (C# only, conceptual reference)](https://github.com/chickensoft-games/GodotTestDriver)
- [godot#107128 — force_drag() does not update drag preview (4.3 bug)](https://github.com/godotengine/godot/issues/107128)
