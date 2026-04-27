# TESTING.md — QA patterns for Claude

Lessons learned about driving the game through `godot-mcp-pro` for automated QA. **Read this before writing any test/playtest sequence.**

## Root cause: MCP calls are async

Every MCP tool call is a round-trip over WebSocket (port 6505). Each call adds ~200–500ms. The game does NOT pause while we wait for our tool call to return — physics keeps stepping at 60 Hz.

Consequence: any sequence like

```
simulate_action(move_right, pressed=true)  # fires instantly
capture_frames(count=6, frame_interval=4)  # queued — starts 200ms+ later
```

will miss the early/mid-motion frames. At MOVE_SPEED=220, 2–3 seconds of queued MCP latency = 400–660 pixels of player travel = already hit the far wall.

**Do not use `simulate_action` followed by separate `capture_frames` / `execute_game_script` calls to verify mid-motion states.** It will not work reliably.

## Known pitfalls

- `capture_frames` sometimes returns visually stale frames relative to the current game state. Trust `get_game_screenshot` or `execute_game_script` state reads over capture_frames images when they disagree.
- `execute_game_script` does **not** support top-level `await` in the outer wrapper. You can only `await` inside a nested function you define in the script. Don't write `await get_tree().create_timer(...).timeout` at the top level — it crashes with "Trying to call an async function without 'await'".
- `_mcp_error` and `UNUSED_PRIVATE_CLASS_VARIABLE` warnings in the debugger come from the MCP plugin's own injected scripts. **Ignore them** — they are not game bugs.
- Inputs pressed via `simulate_action` persist across calls. Always explicitly release (`pressed=false`) at the end of a test, or subsequent tests inherit held keys.

## QA patterns — pick the right one

### Pattern 1: Synchronous harness inside one `execute_game_script` call (PREFERRED)

Runs deterministically inside the game process. No MCP round-trips mid-sequence. Use for anything involving timing, motion, or animation transitions.

```gdscript
var p = get_tree().root.get_node("World/Player")
p.position = Vector2(400, 500)
p.velocity = Vector2.ZERO

var results = []
var step = func():
	Input.action_press("move_right")
	for i in 10:
		await get_tree().physics_frame
	results.append("t=10f: pos=%s anim=%s" % [p.position, p._current_anim])
	for i in 10:
		await get_tree().physics_frame
	results.append("t=20f: pos=%s anim=%s" % [p.position, p._current_anim])
	Input.action_release("move_right")

await step.call()
for line in results:
	_mcp_print(line)
```

Key rules:
- Wrap awaiting logic in a `func() -> void:` lambda, then `await` that call. Top-level `await` will crash.
- Use `await get_tree().physics_frame` to advance exactly one physics step.
- Release every pressed input at the end.
- Save screenshots from inside the script if needed: `get_viewport().get_texture().get_image().save_png("res://screenshots/qa-stepN.png")`.

### Pattern 2: Pause + pose check

Good for confirming rig looks right in a specific animation state. Does NOT validate physics or transitions.

```gdscript
var p = get_tree().root.get_node("World/Player")
p.set_physics_process(false)   # stop _update_animation from overwriting
p.position = Vector2(400, 450)
p._anim.play("run")            # or "jump", "wall_slide", "land", etc.
```

Then call `get_game_screenshot` to capture the static pose. Re-enable `set_physics_process(true)` and restore position before leaving the test.

### Pattern 3: Handoff to human playtest

For feel tuning (jump floatiness, run speed, gravity weight), nothing beats the user playing. Don't try to QA subjective feel — ask for symptoms ("jump feels floaty at apex", "turning around is sluggish") and tune the relevant constant in `player/player.gd`.

### Pattern 4: Drag-and-drop — direct method invocation (synthetic drag from MCP doesn't work end-to-end)

**The bottom line, post hands-off re-verification (2026-04-26):** Recipe A from `research/tools/godot-drag-drop-api.md §3` is *correct in normal Godot contexts* (the targeted crawl confirmed GUT 9.6.0 ships it for Godot 4.6 in Feb 2026). But it does NOT work from inside `execute_game_script` against a Control GUI — and even using the godot-mcp-pro `simulate_*` tools (with the addon patched to honor explicit `unhandled: false`), events reach `_gui_input` correctly but Godot's drag state machine never engages. `_get_drag_data` is not called; `gui_is_dragging` stays `false`. Root cause not isolated this session — likely a `_cmd_execute_script` runtime context issue or a synthetic-event gating step we haven't found. See `tests/RESULTS.md` for the complete data.

**Until that's solved, use direct method invocation as the primary drag-test pattern.** This is a unit test of slot drop-handling logic, NOT an end-to-end GUI drag test. It catches regressions in:
- `_can_drop_data` predicate correctness
- `_drop_data` state mutations
- Position-aware swap behavior
- Multipliers / signals downstream of drops

It does NOT catch:
- `_get_drag_data` correctness (caller-supplied)
- Mouse-filter / hit-test issues
- Drag preview rendering
- Anything that requires real GUI dispatch through the engine's drag state machine

For everything in the second list, **manual playtest by the user is currently the only reliable validation.** That's a real limitation, not a workaround we should pretend solves it.

**The runner**: `tests/run_drag_recipe.gd`. Four positive modes (equip / swap / deactivate / two-stage swap) plus two negative-control rejections (inv→inv, same-slot). Re-run after any change to `SkillCardSlot.gd` or `SkillsPanel.gd`.

- `Input.parse_input_event(InputEventMouseButton)` and `Viewport.push_input(event)` both fail to fire `_gui_input` on the topmost Control under the press position. So the engine never starts a drag, and `_get_drag_data` / `_drop_data` never run from synthetic input.
- `Control.force_drag(data, preview)` engages the drag programmatically but synthetic release does not complete it cleanly — drag ends silently with `gui_is_drag_successful=false` and no state mutation.

The recipe in `research/tools/godot-drag-drop-api.md §3` is documented for completeness and historical reference, but **do not use it as the basis for a drag test in this Godot version**. It will silently pass without validating anything. (May be a Godot 4.6 regression vs. earlier 4.x; not bisected.)

**Working pattern for testing slot drop-handling logic** (a unit test of the routing code, not an end-to-end GUI drag test):

```gdscript
var data: Dictionary = { "skill": source_slot.card.skill, "source_slot": source_slot }
var accepted: bool = target_slot._can_drop_data(Vector2.ZERO, data)
if accepted:
    target_slot._drop_data(Vector2.ZERO, data)
# Now read state — Skills.active, multipliers, slot.card — and assert.
```

The runner at `tests/run_drag_recipe.gd` exercises four modes against the real `SkillsPanel`: equip, swap, deactivate, and two negative controls (inv→inv and same-slot rejection). Re-run after any change to `SkillCardSlot.gd` or `SkillsPanel.gd` to catch regressions in routing rules.

**What this pattern catches**: `_can_drop_data` predicate correctness, `_drop_data` mutations, position-aware swap behavior, multipliers reaching the player.

**What this pattern does NOT catch**: mouse-filter regressions (events not reaching the right Control), drag preview rendering, drag threshold / hit-test issues, anything that requires real OS mouse events through GUI dispatch. Hand off to manual playtest for those.

## Window / screenshot sizing

Project is set to 960×540 viewport with `allow_hidpi=false` specifically to keep QA screenshots small. Do not change these settings without asking — they exist to conserve session context.

Screenshots at this size cost ~15× less than Retina-scaled full-res captures. If a test really needs more detail, capture just the region of interest rather than bumping up the whole viewport.

## Before playtesting the user's build

Do not run long synthetic QA sweeps just to confirm "it still works." The rig and animation keyframes have been validated in prior sessions. Unless a change could have plausibly broken something, trust the code and hand off to the user for feel.
