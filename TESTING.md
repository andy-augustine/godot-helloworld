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

### Pattern 4: Drag-and-drop — synthetic recipe works in Godot 4.6.2 (with patches)

**Resolved 2026-04-26.** End-to-end synthetic drag-and-drop testing against `Control` GUIs IS achievable in Godot 4.6.2 via the godot-mcp-pro `simulate_sequence` tool. The two pieces that were blocking us:

1. **Motion events MUST have non-zero `relative_x`/`relative_y` populated** to match the position deltas. Godot's drag-detection threshold accumulates the `relative` field, not absolute position deltas — with `relative=(0,0)` on every motion, the threshold (~8 px) is never exceeded and drag never engages. This is undocumented.
2. **The local addon patches** at `addons/godot_mcp/commands/input_commands.gd` and `addons/godot_mcp/mcp_input_service.gd` are required so explicit `unhandled: false` overrides the addon's auto-promotion-to-`push_input(event, true)` for motions with `button_mask>0`. Without these patches, drag motions skip GUI hit-testing.

See `tests/RESULTS.md` for the complete data and the working JSON recipe.

**Recommended primary pattern: synthetic drag via `simulate_sequence`** with `frame_delay >= 1`, `unhandled: false` on every motion, and `relative_x`/`relative_y` populated to match position deltas. Wait ~1 second after dispatch, then read state.

**Backup pattern: direct method invocation** for fast, deterministic regression tests of slot drop-handling logic. Faster than synthetic and runs without any input-injection plumbing, but doesn't exercise hit-test or state-machine paths.

```gdscript
var data: Dictionary = { "skill": source_slot.card.skill, "source_slot": source_slot }
var accepted: bool = target_slot._can_drop_data(Vector2.ZERO, data)
if accepted:
    target_slot._drop_data(Vector2.ZERO, data)
# Read state — Skills.active, multipliers, slot.card — and assert.
```

**The runner**: `tests/run_drag_recipe.gd` with two modes:
- **Synthetic mode** — drives the full recipe via `simulate_sequence`. Validates the GUI dispatch path end-to-end.
- **Direct mode** — invokes `_can_drop_data` / `_drop_data` directly. Validates slot routing rules (equip / swap / deactivate / inv→inv reject / same-slot reject). Faster.

Re-run after any change to `SkillCard.gd`, `SkillCardSlot.gd`, or `SkillsPanel.gd`.

**What still doesn't work**: `Input.parse_input_event` and `Viewport.push_input` called from inside `execute_game_script` don't reach `_gui_input` (root cause unknown — likely a `_cmd_execute_script` runtime-context issue). It doesn't matter because the MCP `simulate_*` tools work correctly. Don't try to inline the recipe inside an `execute_game_script` body; use the MCP tools.

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
